import 'package:filmu_nams/views/client/auth/login/login.dart';
import 'package:filmu_nams/views/client/auth/registration/registration.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:flutter/material.dart';

import '../../../providers/style.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  late List<Widget> views;
  int currentView = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    views = [
      Login(onViewChange: toggleView),
      Registration(onViewChange: toggleView),
    ];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleView(int? view) {
    setState(() {
      currentView = view ?? 0;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Style.of(context);

    return Scaffold(
      body: Background(
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top - 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Laipni lūdzam',
                          style: theme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Filmu nams',
                          style: theme.displayLarge,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: theme.cardDecoration,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: views[currentView]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
