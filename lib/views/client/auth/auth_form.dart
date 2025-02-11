import 'package:filmu_nams/views/client/auth/login/login.dart';
import 'package:filmu_nams/views/client/auth/registration/registration.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:filmu_nams/assets/decorations/big_logo.dart';
import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  late List<Widget> views;
  int currentView = 0;

  _AuthFormState() {
    views = [
      Login(onViewChange: toggleView),
      Registration(onViewChange: toggleView),
      Placeholder(),
    ];
  }

  void toggleView(int? view) {
    setState(() {
      currentView = view ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LogoSection(),
              FormContainer(
                child: CarouselSwitch(
                  direction: CarouselSwitchDirection.left,
                  child: views[currentView],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BigLogo(top: height * 0.17);
  }
}

class FormContainer extends StatelessWidget {
  final Widget child;

  const FormContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
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
        child: child,
      ),
    );
  }
}
