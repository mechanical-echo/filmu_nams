import 'package:filmu_nams/views/admin/auth/admin_auth.dart';
import 'package:flutter/material.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminAuth(),
    );
  }
}
