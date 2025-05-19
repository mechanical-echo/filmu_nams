import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/views/admin/auth/admin_login.dart';
import 'package:filmu_nams/views/admin/dashboard/admin_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AdminAuth extends StatelessWidget {
  const AdminAuth({super.key});
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          final user = authSnapshot.data;

          if (user == null) {
            return AdminLogin();
          }

          return FutureBuilder<dynamic>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return Background(
                  child: Center(
                    child: SizedBox(
                      height: height * 0.5,
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }

              if (userDocSnapshot.hasData && userDocSnapshot.data != null) {
                final userData = userDocSnapshot.data!.data();
                if (userData != null && userData['role'] == 'admin') {
                  return AdminWrapper();
                }
              }

              return AdminLogin();
            },
          );
        },
      ),
    );
  }
}
