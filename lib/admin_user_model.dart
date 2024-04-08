import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserModel {
  String uid;
  String name;
  String photoUrl;

  AdminUserModel({required this.uid, required this.name, required this.photoUrl});

  factory AdminUserModel.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return AdminUserModel(
      uid: snapshot.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}