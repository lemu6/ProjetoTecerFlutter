import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReadPostsPage extends StatefulWidget {
  @override
  _ReadPostsPageState createState() => _ReadPostsPageState();
}

class _ReadPostsPageState extends State<ReadPostsPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Posts Lidos'),
        ),
        body: Center(
          child: Text('Você precisa estar logado para ver isso.'),
        ),
      );
    }

    // Usamos o operador ! com segurança aqui porque já fizemos a verificação de nulidade
    final userId = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Posts Lidos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // Usamos userId em vez de user.uid
            .collection('readPosts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ocorreu um erro ao carregar os posts lidos.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum post lido ainda.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var readPostData = snapshot.data!.docs[index].data() as Map<String, dynamic>?;
              if (readPostData == null || !readPostData.containsKey('postId')) {
                return ListTile(
                  title: Text('Detalhes do post não disponíveis.'),
                );
              }
              String? postId = readPostData['postId'] as String?;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Carregando...'));
                  }

                  if (postSnapshot.hasError || !postSnapshot.hasData) {
                    return ListTile(title: Text('Erro ao carregar dados do post.'));
                  }

                  var postData = postSnapshot.data!.data() as Map<String, dynamic>?;
                  if (postData == null) {
                    return ListTile(title: Text('Post não encontrado.'));
                  }
                  String postTitle = postData['title'] as String? ?? 'Sem título';
                  DateTime? readOnDate = (readPostData['readOn'] as Timestamp?)?.toDate();
                  String formattedDate = readOnDate != null ? DateFormat('dd/MM/yyyy').format(readOnDate) : 'Data desconhecida';

                  return ListTile(
                    title: Text(postTitle),
                    subtitle: Text('Lido em: $formattedDate'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
