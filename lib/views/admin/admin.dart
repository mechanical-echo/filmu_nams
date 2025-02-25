import 'package:filmu_nams/views/admin/auth/admin_auth.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:flutter/material.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Wrapper(
      Column(
        children: [
          AdminAuth(),
        ],
      ),
      width,
    );
  }

  Widget Wrapper(Widget child, double width) {
    return Background(
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }
}
