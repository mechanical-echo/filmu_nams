import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  Timestamp createdAt;
  String email;
  String name;
  String profileImageUrl;
  String role;
  String id;

  UserModel({
    required this.id,
    required this.createdAt,
    required this.email,
    required this.name,
    required this.profileImageUrl,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      createdAt: map["createdAt"] ?? '',
      email: map["email"] ?? '',
      name: map["name"] ?? '',
      profileImageUrl: map["profileImageUrl"] ?? '',
      role: map["role"] ?? '',
    );
  }
}
