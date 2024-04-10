import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'post_model.dart'; // Certifique-se de que está apontando para o local correto do arquivo do modelo de post

class PostDetailsPage extends StatefulWidget {
  final BlogPost post;

  PostDetailsPage({required this.post});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 10));
  bool _hasPlayedConfetti = false;
  bool _hasAnsweredQuestions = false; // Indica se o usuário já respondeu as questões.
  Map<String, int> _selectedOptions = {}; // Salva as respostas do usuário para cada questão

  @override
  void initState() {
    super.initState();
    _checkIfAnswered();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _checkIfAnswered() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userQuizzesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('answeredQuizzes')
        .doc(widget.post.id);

      final quizEntry = await userQuizzesRef.get();
      if (quizEntry.exists) {
        setState(() {
          _hasAnsweredQuestions = true;
        });
      }
    }
  }

  Widget _buildQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText),
        ...List.generate(question.options.length, (index) => RadioListTile<int>(
          title: Text(question.options[index]),
          value: index,
          groupValue: _selectedOptions[question.questionText],
          onChanged: (value) {
            if (!_hasAnsweredQuestions) {
              setState(() {
                _selectedOptions[question.questionText] = value!;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Você já respondeu as questões deste post.')),
              );
            }
          },
        )),
        Divider(),
      ],
    );
  }

  void _submitAnswers() async {
    if (_hasAnsweredQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você já respondeu as questões deste post.')),
      );
      return;
    }

    int score = 0;
    int pointsEarned = 0;
    for (var question in widget.post.questions) {
      if (_selectedOptions[question.questionText] == question.correctOptionIndex) {
        score++;
      }
    }

    pointsEarned = score * 5; // 5 pontos por resposta correta

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Atualiza os pontos do usuário no Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(pointsEarned),
      });

      // Atualiza o banco de dados para registrar que o usuário respondeu ao quiz
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('answeredQuizzes')
        .doc(widget.post.id)
        .set({
          'answeredOn': Timestamp.now(),
          'score': score,
        });

      setState(() {
        _hasAnsweredQuestions = true; // Marca que as questões foram respondidas
      });

      if (score == widget.post.questions.length) {
        _confettiController.play();
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Resultado do Quiz'),
            content: Text('Você acertou $score de ${widget.post.questions.length} perguntas e ganhou $pointsEarned pontos.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você precisa estar logado para responder as questões.')),
      );
    }
  }

  void _markAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você precisa estar logado para marcar posts como lidos.')),
      );
      return;
    }

    final readPostsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('readPosts')
        .doc(widget.post.id);

    final postEntry = await readPostsRef.get();

    if (!postEntry.exists) {
      int pointsForReading = 10; // Pontos básicos por ler o post

      await readPostsRef.set({
        'postId': widget.post.id,
        'readOn': Timestamp.now(),
      });

      // Incrementa os pontos do usuário por ler o post e pelas respostas corretas se ainda não respondeu
      if (!_hasAnsweredQuestions) {
        int pointsForCorrectAnswers = _calculatePointsForCorrectAnswers();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(pointsForReading + pointsForCorrectAnswers),
        });
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(pointsForReading),
        });
      }

      if (!_hasPlayedConfetti) {
        _confettiController.play();
        setState(() {
          _hasPlayedConfetti = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post marcado como lido! Você ganhou pontos.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você já marcou este post como lido.')),
      );
    }
  }

  int _calculatePointsForCorrectAnswers() {
    return widget.post.questions
        .where((q) => _selectedOptions[q.questionText] == q.correctOptionIndex)
        .length *
        5; // 5 pontos por resposta correta
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> questionWidgets = widget.post.questions
        .map<Widget>((question) => _buildQuestion(question))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 10),
                Text(
                  widget.post.subtitle,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(height: 20),
                Text(
                  widget.post.content,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 20),
                ...questionWidgets,
                if (widget.post.questions.isNotEmpty)
                  ElevatedButton(
                    onPressed: _submitAnswers,
                    child: Text('Enviar Respostas'),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _markAsRead,
                  child: Text('Marcar como lido e ganhar pontos'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red, Colors.blue, Colors.orange, Colors.purple, Colors.green,
              ],
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.6,
              numberOfParticles: 10,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
