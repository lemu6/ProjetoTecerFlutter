import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  String id;
  String title;
  String subtitle; // Adicionado campo para subtítulo
  String content;
  DateTime dateCreated;
  String authorId;
  String authorName;

  BlogPost({
    required this.id,
    required this.title,
    required this.subtitle, // Subtítulo agora é um campo obrigatório
    required this.content,
    required this.dateCreated,
    required this.authorId,
    required this.authorName,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sem título',
      subtitle: json['subtitle'] ?? '', // Pega o subtítulo do JSON
      content: json['content'] ?? 'Sem conteúdo', // Assume que o content vem como uma string JSON
      dateCreated: (json['dateCreated'] as Timestamp).toDate(),
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Anônimo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle, // Inclui o subtítulo na serialização para JSON
      'content': content, // Content já é uma string JSON, então só passa adiante
      'dateCreated': Timestamp.fromDate(dateCreated),
      'authorId': authorId,
      'authorName': authorName,
    };
  }
}
