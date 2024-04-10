import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logintest/ReadPostsPage.dart';
import 'package:logintest/RegisterPageStep2.dart';
import 'package:logintest/register_page.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/registerStep1': (context) => RegisterPageStep1(),
        '/home': (context) => MainScreen(), // Changed from '/home' to '/main'
        '/registerStep2': (context) => RegisterPageStep2(userId: ModalRoute.of(context)!.settings.arguments as String),
        '/readPostsPage': (context) => ReadPostsPage(),
      },
    );
  }
}