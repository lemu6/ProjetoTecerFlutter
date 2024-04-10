import 'package:flutter/material.dart';
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

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'],
      options: List<String>.from(map['options']),
      correctOptionIndex: map['correctOptionIndex'],
    );
  }
}

class Quiz {
  String id;
  String title;
  List<Question> questions;
  DateTime endDate;  // Adicione esta linha

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    required this.endDate,  // Adicione este parâmetro
  });

  static Quiz fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Quiz(
      id: snapshot.id,
      title: data['title'],
      questions: List<Question>.from(data['questions'].map((q) => Question.fromMap(q))),
      endDate: DateTime.fromMillisecondsSinceEpoch(data['endDate']),  // Converter timestamp para DateTime
    );
  }
}


class QuizCard extends StatelessWidget {
  final Question question;

  const QuizCard({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.withOpacity(0.8), Colors.blue.withOpacity(0.5)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.questionText.length > 50 ? question.questionText.substring(0, 50) + '...' : question.questionText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ...question.options.asMap().entries.map((entry) {
                int idx = entry.key;
                String val = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    val,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
