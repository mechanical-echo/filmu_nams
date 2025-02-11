import 'package:filmu_nams/views/admin/auth/admin_auth.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/decorations/logo.dart';
import 'package:flutter/material.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Wrapper(
      Column(
        children: [
          SizedBox(height: 120),
          AdminAuth(),
        ],
      ),
      width,
    );
  }

  Widget Wrapper(Widget child, double width) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(200),
          child: Logo(),
        ),
        body: SizedBox(
          width: width,
          child: SingleChildScrollView(
            child: child,
          ),
        ),
      ),
    );
  }
}
