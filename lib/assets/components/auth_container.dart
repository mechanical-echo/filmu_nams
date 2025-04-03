import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomAction;
  final double? width;
  final double? height;

  const AuthContainer({
    super.key,
    required this.title,
    required this.child,
    this.bottomAction,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Container(
      width: width ?? size.width * 0.9,
      height: height,
      constraints: BoxConstraints(
        maxWidth: 500,
        minHeight: height ?? 600,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
          if (bottomAction != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: bottomAction,
            ),
        ],
      ),
    );
  }
}
