import 'package:flutter/material.dart';

class Challenge {
  final String title;
  final String description;

  Challenge({required this.title, required this.description});

  static Challenge fromSnapshot(snapshot) {
    var data = snapshot.data();
    return Challenge(title: data['title'], description: data['description']);
  }
}

class ChallengeDetailsPage extends StatelessWidget {
  final Challenge challenge;

  ChallengeDetailsPage({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Desafio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: ${challenge.title}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Descrição: ${challenge.description}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
