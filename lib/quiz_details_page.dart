import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';

class Question {
  String questionText;
  List<String> options;
  int correctOptionIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'],
      options: List<String>.from(map['options']),
      correctOptionIndex: map['correctOptionIndex'],
    );
  }
}

class QuizDetailsPage extends StatefulWidget {
  final String quizId;

  QuizDetailsPage({required this.quizId});

  @override
  _QuizDetailsPageState createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  List<Question> _questions = [];
  Map<int, int> _selectedOptions = {}; // Question index and selected option index
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 10));
  bool _isSubmitted = false;
  bool _userAlreadySubmitted = false;

  @override
  void initState() {
    super.initState();
    _fetchQuiz();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuiz() async {
    // Check if the user already submitted
    await _checkIfUserAlreadySubmitted();

    // Fetch quiz questions
    DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).get();
    var data = quizSnapshot.data() as Map<String, dynamic>;
    List<Question> questions = List<Question>.from(data['questions'].map((q) => Question.fromMap(q)));

    setState(() {
      _questions = questions;
    });
  }

Future<void> _checkIfUserAlreadySubmitted() async {
  DocumentSnapshot submissionSnapshot = await FirebaseFirestore.instance.collection('user_submissions').doc('userId').get();
  if (submissionSnapshot.exists) {
    Map<String, dynamic> data = submissionSnapshot.data() as Map<String, dynamic>;
    String submittedQuizId = data['quizId'];
    setState(() {
      _userAlreadySubmitted = submittedQuizId == widget.quizId;
    });
  }
}


  void _selectOption(int questionIndex, int optionIndex) {
    if (_userAlreadySubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already submitted this quiz.')),
      );
      return;
    }

    setState(() {
      _selectedOptions[questionIndex] = optionIndex;
    });
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitted || _userAlreadySubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already submitted this quiz.')),
      );
      return;
    }

    int correctAnswers = _selectedOptions.entries
      .where((entry) => _questions[entry.key].correctOptionIndex == entry.value)
      .length;
    double totalScore = (correctAnswers / _questions.length) * 10;

    // Save user's submission to Firestore
    await _saveUserSubmission();

    setState(() {
      _isSubmitted = true;
    });

    if (correctAnswers == _questions.length) {
      _confettiController.play();
      _showSuccessDialog();
    } else {
      _showScoreDialog(totalScore);
    }
  }

  Future<void> _saveUserSubmission() async {
    await FirebaseFirestore.instance.collection('user_submissions').doc('userId').set({
      'quizId': widget.quizId,
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You answered all questions correctly!'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showScoreDialog(double totalScore) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Completed'),
        content: Text('You scored ${totalScore.toStringAsFixed(2)} out of 10.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Details'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(question.questionText),
                    ),
                    ...question.options.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String val = entry.value;
                      return RadioListTile<int>(
                        title: Text(val),
                        value: idx,
                        groupValue: _selectedOptions[index],
                        onChanged: !_isSubmitted ? (value) => _selectOption(index, value!) : null,
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              maxBlastForce: 20, // set a lower max blast force
              minBlastForce: 8, // set a lower min blast force
              emissionFrequency: 0.05, // set a lower emission frequency
              numberOfParticles: 50, // a lot of particles
              gravity: 0.5, // gravity is high
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitQuiz,
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
    );
  }
}
