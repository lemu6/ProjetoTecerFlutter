import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'post_model.dart'; // Substitua pelo caminho correto do seu modelo de post

class PostDetailsPage extends StatefulWidget {
  final BlogPost post;

  PostDetailsPage({required this.post});

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  bool _hasPlayedConfetti = false; // Adicione esta linha para controlar o estado de execução do confete

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _markAsRead(BuildContext context) async {
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
        .collection('readPosts');

    final postEntry = await readPostsRef.doc(widget.post.id).get();

    if (!postEntry.exists) {
      try {
        await readPostsRef.doc(widget.post.id).set({
          'postId': widget.post.id,
          'readOn': Timestamp.now(),
        });

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(10),
        });

        if (!_hasPlayedConfetti) {
          _confettiController.play();
          setState(() {
            _hasPlayedConfetti = true; // Marca que o confete foi executado
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post marcado como lido! Você ganhou 10 pontos.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro ao marcar o post como lido: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você já marcou este post como lido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 10),
                Text(
                  widget.post.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _markAsRead(context),
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
                Colors.red, Colors.blue, Colors.orange, Colors.purple, Colors.green
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
