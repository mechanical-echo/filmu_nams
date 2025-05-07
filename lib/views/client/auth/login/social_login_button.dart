import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = Style.of(context);

    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: style.cardDecoration,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            FittedBox(
              child: Text(
                label,
                style: style.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
