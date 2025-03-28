import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  const FormInput({
    super.key,
    required this.heightLines,
    required this.title,
    required this.controller,
    required this.icon,
    this.isPassword = false,
  });

  final int heightLines;
  final String title;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(
              icon,
              size: 25,
              color: smokeyWhite,
            ),
            Text(title, style: bodyLarge),
          ],
        ),
        TextFormField(
          controller: controller,
          keyboardType: isPassword
              ? TextInputType.visiblePassword
              : TextInputType.multiline,
          minLines: heightLines,
          maxLines: heightLines,
          obscureText: isPassword,
        ),
      ],
    );
  }
}
