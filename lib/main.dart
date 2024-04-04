import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override  
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Tecer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.deepOrange,
    ),
    //home: LoginPage(),
    ); 
  }
}

