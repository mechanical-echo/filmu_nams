import 'package:filmu_nams/views/auth/registration_first_step.dart';
import 'package:filmu_nams/views/auth/registration_second_step.dart';
import 'package:filmu_nams/views/resources/carousel_switch.dart';
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
    RegistrationFirstStep(
      nextRegistrationStep: nextStep,
      onViewChange: widget.onViewChange,
      emailController: emailController,
      passwordController: passwordController,
      passwordConfirmationController: passwordConfirmationController,
    ),
    RegistrationSecondStep(
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
