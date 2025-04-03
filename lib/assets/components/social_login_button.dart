import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:filmu_nams/providers/color_context.dart';

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
    final colors = ColorContext.of(context);
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;
    final effectiveTextColor = textColor ?? Colors.black;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
