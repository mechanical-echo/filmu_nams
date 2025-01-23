import 'package:filmu_nams/views/auth/login.dart';
import 'package:filmu_nams/views/auth/registration.dart';
import 'package:filmu_nams/views/resources/background.dart';
import 'package:filmu_nams/views/resources/big_logo.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  late List<Widget> views;

  _AuthFormState() {
    views = [
      Login(onPressed: () => toggleView(1)),
      Registration(),
      Placeholder(),
    ];
  }

  int currentView = 0;

  void toggleView(int view) {
    setState(() {
      currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Background(
        child: Column(
          children: [
            BigLogo(
              top: 164,
            ),
            Container(
              margin: const EdgeInsets.only(top: 100, right: 25, left: 25),
              width: width,
              height: 475,
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: views[currentView],
            ),
          ],
        ),
      ),
    );
  }
}
