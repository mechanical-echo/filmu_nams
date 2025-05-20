import 'package:filmu_nams/providers/theme_provider.dart';
import 'package:filmu_nams/views/client/auth/login/login.dart';
import 'package:filmu_nams/views/client/auth/registration/registration.dart';
import 'package:filmu_nams/assets/decorations/background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  Style get theme => Style.of(context);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Background(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top - 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          left: 0,
                          child: IconButton(
                            icon: Icon(
                              theme.isDark ? Icons.light_mode : Icons.dark_mode,
                            ),
                            onPressed: () => themeProvider.setTheme(theme.isDark
                                ? AppTheme.redLight
                                : AppTheme.redDark),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Laipni lūdzam',
                              style: theme.displayMedium,
                            ),
                            Text(
                              'Filmu nams',
                              style: theme.displayLarge.copyWith(
                                fontSize: 42,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 20, top: 20),
                        decoration: (theme.isDark
                                ? theme.opaqueCardDecoration
                                : theme.cardDecoration)
                            .copyWith(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: views[currentView],
                        ),
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
