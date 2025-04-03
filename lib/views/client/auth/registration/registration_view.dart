import 'package:flutter/material.dart';

class RegistrationView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onConfirmPasswordVisibilityToggle;
  final VoidCallback onRegistration;
  final void Function(int? view) onViewChange;
  final Widget child;

  const RegistrationView({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onPasswordVisibilityToggle,
    required this.onConfirmPasswordVisibilityToggle,
    required this.onRegistration,
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
