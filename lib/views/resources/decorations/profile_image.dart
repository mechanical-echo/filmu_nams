import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  ProfileImage({
    super.key,
    required this.width,
  });

  final double width;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: width,
      height: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: user!.photoURL != null
          ? Image.network(
              user!.photoURL!,
              fit: BoxFit.cover,
            )
          : Icon(
              Icons.person,
              size: 85,
              color: Colors.white,
            ),
    );
  }
}
