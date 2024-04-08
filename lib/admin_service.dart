import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_user_model.dart'; // Certifique-se de que este caminho está correto conforme o local do seu arquivo de modelo

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Esta função busca todos os usuários marcados como administradores no Firestore
  // e os converte para uma lista de AdminUserModel.
  Future<List<AdminUserModel>> fetchAdmins() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users')
      .where('isAdmin', isEqualTo: true)
      .get();

    return querySnapshot.docs
      .map((doc) => AdminUserModel.fromSnapshot(doc))
      .toList();
  }
}