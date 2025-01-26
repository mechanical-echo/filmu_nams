import 'package:filmu_nams/views/auth/login.dart';
import 'package:filmu_nams/views/auth/registration.dart';
import 'package:filmu_nams/views/resources/decorations/background.dart';
import 'package:filmu_nams/views/resources/decorations/big_logo.dart';
import 'package:filmu_nams/views/resources/animations/carousel_switch.dart';
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
      Login(onViewChange: toggleView),
      Registration(onViewChange: toggleView),
      Placeholder(),
    ];
  }

  int currentView = 0;

  void toggleView(int? view) {
    setState(() {
      currentView = view ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Background(
          child: SingleChildScrollView(
        child: Column(
          children: [
            BigLogo(top: height * 0.17),
            Container(
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.only(
                top: height * 0.06,
                right: 25,
                left: 25,
                bottom: 25,
              ),
              padding: const EdgeInsets.only(bottom: 25),
              width: width,
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.linearToEaseOut,
                child: CarouselSwitch(
                  direction: CarouselSwitchDirection.left,
                  child: views[currentView],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
