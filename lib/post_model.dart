import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String questionText;
  List<String> options;
  int correctOptionIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}

class BlogPost {
  String id;
  String title;
  String subtitle;
  String content;
  DateTime dateCreated;
  String authorId;
  String authorName;
  List<Question> questions;

  BlogPost({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.dateCreated,
    required this.authorId,
    required this.authorName,
    required this.questions,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sem título',
      subtitle: json['subtitle'] ?? '',
      content: json['content'] ?? 'Sem conteúdo',
      dateCreated: (json['dateCreated'] as Timestamp).toDate(),
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? 'Anônimo',
      questions: (json['questions'] as List<dynamic>? ?? []).map((q) => Question.fromJson(q)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'authorId': authorId,
      'authorName': authorName,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

