import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/models/user.dart';

class NotificationModel {
  final String id;
  final String message;
  final String title;
  final String status;
  final String type;
  final UserModel user;

  NotificationModel({
    required this.id,
    required this.message,
    required this.title,
    required this.status,
    required this.type,
    required this.user,
  });

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
    UserModel user,
    String id,
  ) {
    return NotificationModel(
      id: id,
      message: map['message'] ?? '',
      title: map['title'] ?? '',
      status: map['status'] ?? '',
      type: map['type'] ?? '',
      user: user,
    );
  }

  static Future<NotificationModel> fromMapAsync(
    Map<String, dynamic> map,
    String id,
  ) async {
    final userSnapshot = await map['user'].get();
    final user = UserModel.fromMap(userSnapshot.data(), userSnapshot.id);

    return NotificationModel.fromMap(map, user, id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'message': message,
      'title': title,
      'status': status,
      'type': type,
    };
  }
}
