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
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userController.userHasRole(user, "role");
      return AdminDashboard();
    }

    return AdminLogin();
  }
}
