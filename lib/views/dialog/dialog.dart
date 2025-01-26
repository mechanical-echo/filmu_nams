import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylizedDialog {
  static void alert(BuildContext context, String title, String content) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        title: Stack(
          children: [
            Positioned(
              left: 0,
              child: Icon(
                Icons.error,
                color: Theme.of(context)
                    .filledButtonTheme
                    .style
                    ?.backgroundColor
                    ?.resolve({WidgetState.pressed}),
                size: 30,
              ),
            ),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
