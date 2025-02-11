import 'package:filmu_nams/views/client/auth/registration/registration_steps/credentials_step.dart';
import 'package:filmu_nams/views/client/auth/registration/registration_steps/profile_setup_step.dart';
import 'package:filmu_nams/assets/animations/carousel_switch.dart';
import 'package:flutter/material.dart';

class Registration extends StatefulWidget {
  final Function(int) onViewChange;
  const Registration({super.key, required this.onViewChange});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final nameController = TextEditingController();

  late List<Widget> views = [
    CredentialsStep(
      nextRegistrationStep: nextStep,
      onViewChange: widget.onViewChange,
      emailController: emailController,
      passwordController: passwordController,
      passwordConfirmationController: passwordConfirmationController,
    ),
    ProfileSetupStep(
      previousRegistrationStep: previousStep,
      nameController: nameController,
      emailController: emailController,
      passwordController: passwordController,
      passwordConfirmationController: passwordConfirmationController,
    ),
  ];

  int currentView = 0;

  void nextStep() {
    setState(() {
      currentView = 1;
    });
  }

  void previousStep() {
    setState(() {
      currentView = 0;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSwitch(
          direction: currentView == 1
              ? CarouselSwitchDirection.left
              : CarouselSwitchDirection.right,
          child: views[currentView],
        ),
      ],
    );
  }
}
