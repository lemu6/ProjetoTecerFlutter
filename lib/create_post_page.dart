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
  bool _isLoading = false;
  String _feedback = '';

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
          id: '', // Será preenchido automaticamente pelo Firestore
          title: _title,
          subtitle: _subtitle,
          content: _content,
          dateCreated: DateTime.now(),
          authorId: user.uid,
          authorName: user.email ?? 'Anônimo',
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
                    SizedBox(height: 20),
                    if (_feedback.isNotEmpty)
                      Text(_feedback, style: TextStyle(color: Colors.red, fontSize: 16)),
                    ElevatedButton(
                      onPressed: _savePost,
                      child: Text('Salvar Post'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}