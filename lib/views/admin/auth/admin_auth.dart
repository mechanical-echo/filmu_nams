import 'package:filmu_nams/views/admin/auth/admin_login.dart';
import 'package:filmu_nams/controllers/user_controller.dart';
import 'package:filmu_nams/views/admin/dashboard/admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminAuth extends StatelessWidget {
  const AdminAuth({super.key});
  @override
  Widget build(BuildContext context) {
    UserController userController = UserController();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        return FutureBuilder<bool>(
          future: user != null
              ? userController.userHasRole(user, "admin")
              : Future.value(false),
          builder: (context, roleSnapshot) {
            if (user != null && roleSnapshot.data == true) {
              return AdminDashboard();
            } else if (user != null && roleSnapshot.data == false) {
              FirebaseAuth.instance.signOut();
            }
            return AdminLogin();
          },
        );
      },
    );
  }
}
