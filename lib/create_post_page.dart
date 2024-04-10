import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart'; // Seu AuthService
import 'post_model.dart'; // Seu BlogPost Model

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _title = '';
  String _subtitle = '';
  String _content = '';
  List<Question> _questions = [];
  bool _isLoading = false;
  String _feedback = '';

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
            child: ListBody(
              children: <Widget>[
                TextField(
                  onChanged: (value) => questionText = value,
                  decoration: InputDecoration(hintText: 'Digite o texto da pergunta'),
                  controller: TextEditingController(text: questionText),
                ),
                ...List.generate(4, (index) => TextField(
                  onChanged: (value) {
                    options[index] = value;
                  },
                  decoration: InputDecoration(hintText: 'Opção ${index + 1}'),
                  controller: TextEditingController(text: options[index]),
                )),
                DropdownButton<int>(
                  value: correctOptionIndex,
                  onChanged: (int? newValue) {
                    setState(() {
                      correctOptionIndex = newValue!;
                    });
                  },
                  items: <int>[0, 1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Opção ${value + 1}'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(question == null ? 'Adicionar' : 'Salvar'),
              onPressed: () {
                if (index == null) {
                  _questions.add(Question(
                    questionText: questionText,
                    options: options,
                    correctOptionIndex: correctOptionIndex,
                  ));
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

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final isAdmin = await _authService.isUserAdmin();
      if (!isAdmin) {
        setState(() => _feedback = 'Apenas administradores podem criar posts.');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newPost = BlogPost(
          id: '',
          title: _title,
          subtitle: _subtitle,
          content: _content,
          dateCreated: DateTime.now(),
          authorId: user.uid,
          authorName: user.email ?? 'Anônimo',
          questions: _questions,
        );

        final docRef = await FirebaseFirestore.instance.collection('posts').add(newPost.toJson());
        await FirebaseFirestore.instance.collection('posts').doc(docRef.id).update({'id': docRef.id});

        setState(() => _feedback = 'Post salvo com sucesso!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _feedback = 'Erro ao salvar o post: $e');
    } finally {
      setState(() => _isLoading = false);
    }

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
                      children: <Widget>[
                        TextField(
                          onChanged: (value) => questionText = value,
                          decoration: InputDecoration(hintText: 'Digite o texto da pergunta'),
                          controller: TextEditingController(text: questionText),
                        ),
                        ...List.generate(4, (i) => TextField(
                          onChanged: (value) {
                            options[i] = value;
                          },
                          decoration: InputDecoration(hintText: 'Opção ${i + 1}'),
                          controller: TextEditingController(text: options[i]),
                        )),
                        DropdownButton<int>(
                          value: correctOptionIndex,
                          onChanged: (int? newValue) {
                            correctOptionIndex = newValue!;
                            setState(() {});
                          },
                          items: List<DropdownMenuItem<int>>.generate(4, (i) => DropdownMenuItem<int>(
                            value: i,
                            child: Text('Opção ${i + 1}'),
                          )),
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
                          _questions.add(Question(
                            questionText: questionText,
                            options: options,
                            correctOptionIndex: correctOptionIndex,
                          ));
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

  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Criar Post')),
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
                    decoration: InputDecoration(labelText: 'Título'),
                    onSaved: (value) => _title = value!,
                    validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira um título' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Subtítulo'),
                    onSaved: (value) => _subtitle = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Conteúdo'),
                    onSaved: (value) => _content = value!,
                    maxLines: 10,
                    validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira algum conteúdo' : null,
                  ),
                  for (int i = 0; i < _questions.length; i++)
                    ListTile(
                      title: Text('Pergunta: ${_questions[i].questionText}'),
                      subtitle: Text('Resposta correta: Opção ${_questions[i].correctOptionIndex + 1}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _addOrEditQuestion(question: _questions[i], index: i),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteQuestion(i),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
Container(
                    margin: EdgeInsets.only(bottom: 12), // Margem abaixo do botão
                    child: ElevatedButton(
                      onPressed: () => _addOrEditQuestion(),
                      child: Text('Adicionar Questão'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue, // Cor do texto
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),

                  // Botão para salvar o post

                  if (_feedback.isNotEmpty)
                    Text(_feedback, style: TextStyle(color: Colors.red, fontSize: 16)),
                  ElevatedButton(
                    onPressed: _savePost,
                    child: Text('Salvar Post'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green, // Cor do texto
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}

}
