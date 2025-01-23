import 'package:flutter/material.dart';

class FilledButtonIcon extends StatelessWidget {
  const FilledButtonIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
    required this.padding_y,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final double padding_y;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding_y),
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
