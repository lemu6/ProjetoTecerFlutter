import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isUserAdmin() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>; // Casting para Map<String, dynamic>
      return data['isAdmin'] ?? false; // Acessando como um mapa
    }
    return false; // Retorna falso se não estiver logado
  }
}
