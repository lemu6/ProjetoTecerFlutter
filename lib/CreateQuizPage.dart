import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';  // Importação necessária para formatar datas
import 'auth_service.dart'; // Serviço de autenticação

// Modelo para uma questão de quiz
class Question {
  String questionText;
  List<String> options;
  int correctOptionIndex;

  Question(
      {required this.questionText,
      required this.options,
      required this.correctOptionIndex});

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}

class CreateQuizPage extends StatefulWidget {
  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _title = '';
  List<Question> _questions = [];
  bool _isLoading = false;
  String _feedback = '';
  DateTime? _startDate;
  DateTime? _endDate;

  void _addOrEditQuestion({Question? question, int? index}) {
    String questionText = question?.questionText ?? '';
    List<String> options = question?.options ?? ['', '', '', ''];
    int correctOptionIndex = question?.correctOptionIndex ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(question == null ? 'Adicionar Questão' : 'Editar Questão'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  onChanged: (value) {
                    questionText = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Texto da pergunta',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: questionText,
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    4,
                    (i) => TextFormField(
                      onChanged: (value) {
                        options[i] = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Opção ${i + 1}',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: options[i],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: correctOptionIndex,
                  onChanged: (int? newValue) {
                    setState(() {
                      correctOptionIndex = newValue!;
                    });
                  },
                  items: List.generate(
                    4,
                    (i) => DropdownMenuItem<int>(
                      value: i,
                      child: Text('Opção ${i + 1}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(question == null ? 'Adicionar' : 'Atualizar'),
              onPressed: () {
                if (index == null) {
                  _questions.add(
                    Question(
                      questionText: questionText,
                      options: options,
                      correctOptionIndex: correctOptionIndex,
                    ),
                  );
                } else {
                  _questions[index] = Question(
                    questionText: questionText,
                    options: options,
                    correctOptionIndex: correctOptionIndex,
                  );
                }
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveQuiz() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) {
      setState(() => _feedback = 'Erro: Certifique-se de que todas as informações e datas estão corretas.');
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final quizData = {
          'title': _title,
          'questions': _questions.map((q) => q.toJson()).toList(),
          'dateCreated': DateTime.now(),
          'startDate': _startDate!.millisecondsSinceEpoch,  // Salva como timestamp
          'endDate': _endDate!.millisecondsSinceEpoch,      // Salva como timestamp
          'authorId': user.uid,
        };

        final docRef =
            await FirebaseFirestore.instance.collection('quizzes').add(quizData);
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(docRef.id)
            .update({'id': docRef.id});

        setState(() => _feedback = 'Quiz criado com sucesso!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _feedback = 'Erro ao salvar o quiz: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Quiz')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Título do Quiz',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => _title = value!,
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Por favor, insira um título' : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _pickDate(context, true),
                      child: Text('Definir Data de Início'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _pickDate(context, false),
                      child: Text('Definir Data de Término'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_questions.isNotEmpty) ...[
                      ..._questions.map((q) => Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                'Pergunta: ${q.questionText}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Resposta correta: Opção ${q.correctOptionIndex + 1}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _addOrEditQuestion(
                                      question: q,
                                      index: _questions.indexOf(q),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => setState(() => _questions.remove(q)),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      SizedBox(height: 20),
                    ],
                    ElevatedButton(
                      onPressed: () => _addOrEditQuestion(),
                      child: Text('Adicionar Questão'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_feedback.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(_feedback, style: TextStyle(color: Colors.red, fontSize: 16)),
                      ),
                    if (_questions.isNotEmpty)
                      ElevatedButton(
                        onPressed: _saveQuiz,
                        child: Text('Salvar Quiz'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
