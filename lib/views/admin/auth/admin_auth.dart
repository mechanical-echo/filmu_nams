import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/views/admin/auth/admin_login.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/views/admin/dashboard/admin_wrapper.dart';
import 'package:filmu_nams/assets/components/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminAuth extends StatelessWidget {
  const AdminAuth({super.key});
  @override
  Widget build(BuildContext context) {
    UserController userController = UserController();
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          final user = authSnapshot.data;

          return FutureBuilder<dynamic>(
            future: user != null
                ? userController.getUserById(user.uid)
                : Future.value(null),
            builder: (context, userDocSnapshot) {
              if (user != null &&
                  userDocSnapshot.data != null &&
                  userDocSnapshot.data.role == 'admin') {
                return AdminWrapper();
              } else if (user != null && userDocSnapshot.data == null) {
                return Background(
                  child: Center(
                    child: SizedBox(
                      height: height * 0.5,
                      child: const LoadingIndicator(
                        type: LoadingAnimationType.stretchedDots,
                        size: 100,
                      ),
                    ),
                  ),
                );
              }
              return AdminLogin();
            },
          );
        },
      ),
    );
  }
}
