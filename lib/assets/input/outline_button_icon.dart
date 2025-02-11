import 'package:flutter/material.dart';

class OutlineButtonIcon extends StatelessWidget {
  const OutlineButtonIcon({
    super.key,
    required this.title,
    required this.onPressed,
    required this.icon,
  });
  final String title;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: SizedBox(
        height: 50,
        width: 225,
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
