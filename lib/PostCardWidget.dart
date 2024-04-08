import 'package:flutter/material.dart';
import 'post_model.dart'; // Substitua pelo caminho correto do seu modelo de post
import 'post_details_page.dart'; // Substitua pelo caminho correto da página de detalhes do post

class PostCardWidget extends StatelessWidget {
  final BlogPost post;
  final double cardWidth = 250.0; // Defina uma largura fixa para os cards, se necessário

  PostCardWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navegar para a página de detalhes do post
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsPage(post: post),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          width: cardWidth, // Usa a largura fixa definida acima
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.indigo],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Título e conteúdo vão aqui como estão
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
              Spacer(), // Empurra o conteúdo para cima e o nome do autor para baixo
              // Nome do autor e data na parte inferior
              Text(
                'Por ${post.authorName}',
                style: TextStyle(
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70, // Ajuste a cor conforme necessário
                ),
              ),
              Text(
                '${post.dateCreated.day}/${post.dateCreated.month}/${post.dateCreated.year}',
                style: TextStyle(
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70, // Ajuste a cor conforme necessário
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}