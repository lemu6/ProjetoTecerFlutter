import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPageStep1 extends StatefulWidget {
  @override
  _RegisterPageStep1State createState() => _RegisterPageStep1State();
}

class _RegisterPageStep1State extends State<RegisterPageStep1> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _registerStep1() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text, password: _passwordController.text);
        Navigator.of(context).pushNamed('/registerStep2',
            arguments: userCredential.user!.uid);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Falha no registro: ${e.message}"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register - Step 1',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.0),
        ),
        backgroundColor: Color(0xFF3366FF),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              Image.asset(
                'assets/logo.png',
                height: 100.0,
              ),
              SizedBox(height: 40.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Color(0xFF3366FF)),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@'))
                    return 'Digite um email válido';
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: '********',
                  prefixIcon: Icon(Icons.lock_outline),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color:Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Color(0xFF3366FF)),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6)
                    return 'A senha precisa ter no mínimo 6 caracteres';
                  return null;
                },
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: _registerStep1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3366FF),
                  minimumSize: Size(double.infinity, 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Continue to Step 2',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
