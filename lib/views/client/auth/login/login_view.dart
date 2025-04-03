import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onLogin;
  final void Function(int? view) onViewChange;
  final Widget child;

  const LoginView({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.onPasswordVisibilityToggle,
    required this.onLogin,
    required this.onViewChange,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: child,
    );
  }
}
