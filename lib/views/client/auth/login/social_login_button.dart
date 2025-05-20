import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';

class SocialLoginButton extends StatefulWidget {
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
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> {
  Style get style => Style.of(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        decoration: style.cardDecoration,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 20,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Image.asset(
              widget.iconPath,
              width: 24,
              height: 24,
              color: style.isDark ? Colors.white60 : theme.primaryColor,
            ),
            FittedBox(
              child: Text(
                widget.label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
