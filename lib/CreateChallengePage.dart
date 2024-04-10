import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateChallengePage extends StatefulWidget {
  @override
  _CreateChallengePageState createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  bool _isLoading = false;
  String _feedback = '';

  void _saveChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final challengeData = {
          'title': _title,
          'description': _description,
          'dateCreated': DateTime.now(),
          'creatorId': user.uid,
        };

        final docRef = await FirebaseFirestore.instance.collection('challenges').add(challengeData);
        await FirebaseFirestore.instance.collection('challenges').doc(docRef.id).update({'id': docRef.id});

        setState(() => _feedback = 'Desafio criado com sucesso!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _feedback = 'Erro ao salvar o desafio: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Desafio'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Título do Desafio'),
                      onSaved: (value) => _title = value!,
                      validator: (value) => value == null || value.isEmpty ? 'Por favor, insira um título' : null,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Descrição do Desafio'),
                      onSaved: (value) => _description = value!,
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Por favor, insira uma descrição' : null,
                    ),
                    SizedBox(height: 20),
                    if (_feedback.isNotEmpty)
                      Text(_feedback, style: TextStyle(color: Colors.red, fontSize: 16)),
                    ElevatedButton(
                      onPressed: _saveChallenge,
                      child: Text('Salvar Desafio'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green, // foreground
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
