import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _ageController;
  late TextEditingController _cityController;
  late TextEditingController _genderController;
  late TextEditingController _motherNameController;
  late TextEditingController _quilomboNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _surnameController = TextEditingController(text: widget.userData['surname']);
    _ageController = TextEditingController(text: widget.userData['age'].toString());
    _cityController = TextEditingController(text: widget.userData['city']);
    _genderController = TextEditingController(text: widget.userData['gender']);
    _motherNameController = TextEditingController(text: widget.userData['motherName']);
    _quilomboNameController = TextEditingController(text: widget.userData['quilomboName']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nome'),
          ),
          TextFormField(
            controller: _surnameController,
            decoration: InputDecoration(labelText: 'Sobrenome'),
          ),
          TextFormField(
            controller: _ageController,
            decoration: InputDecoration(labelText: 'Idade'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(labelText: 'Cidade'),
          ),
          TextFormField(
            controller: _genderController,
            decoration: InputDecoration(labelText: 'Gênero'),
          ),
          TextFormField(
            controller: _motherNameController,
            decoration: InputDecoration(labelText: 'Nome da Mãe'),
          ),
          TextFormField(
            controller: _quilomboNameController,
            decoration: InputDecoration(labelText: 'Nome do Quilombo'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _updateProfile(context),
            child: Text('Salvar Alterações'),
          ),
        ],
      ),
    );
  }

  void _updateProfile(BuildContext context) {
    Map<String, dynamic> updates = {};
    bool isUpdated = false;

    if (_nameController.text != widget.userData['name']) {
      updates['name'] = _nameController.text;
      isUpdated = true;
    }
    if (_surnameController.text != widget.userData['surname']) {
      updates['surname'] = _surnameController.text;
      isUpdated = true;
    }
    int? age = int.tryParse(_ageController.text);
    if (age != null && age != widget.userData['age']) {
      updates['age'] = age;
      isUpdated = true;
    }
    if (_cityController.text != widget.userData['city']) {
      updates['city'] = _cityController.text;
      isUpdated = true;
    }
    if (_genderController.text != widget.userData['gender']) {
      updates['gender'] = _genderController.text;
      isUpdated = true;
    }
    if (_motherNameController.text != widget.userData['motherName']) {
      updates['motherName'] = _motherNameController.text;
      isUpdated = true;
    }
    if (_quilomboNameController.text != widget.userData['quilomboName']) {
      updates['quilomboName'] = _quilomboNameController.text;
      isUpdated = true;
    }

    if (isUpdated) {
      FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(updates)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Perfil atualizado com sucesso!, atualiza a página para carregar')),
          );
          Navigator.pop(context);
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar o perfil: $error')),
          );
        });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhuma mudança para salvar.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _genderController.dispose();
    _motherNameController.dispose();
    _quilomboNameController.dispose();
    super.dispose();
  }
}
