import 'package:flutter/material.dart';

class FilledTextIconButton extends StatelessWidget {
  const FilledTextIconButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
    required this.paddingY,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final double paddingY;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingY),
      child: FilledButton(
        onPressed: onPressed,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Center(child: Text(title)),
            Positioned(
              left: 1,
              child: Icon(icon, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
