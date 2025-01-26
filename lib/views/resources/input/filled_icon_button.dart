import 'package:flutter/material.dart';

class FilledIconButton extends StatelessWidget {
  const FilledIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: FilledButton(
        onPressed: () {},
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
        ),
        child: Icon(
          icon,
          size: 30,
        ),
      ),
    );
  }
}
