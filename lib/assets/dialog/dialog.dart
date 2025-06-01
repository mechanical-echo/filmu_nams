import 'package:filmu_nams/providers/style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylizedDialog {
  static void dialog(
      IconData icon, BuildContext context, String title, String content,
      {Function()? onConfirm, Function()? onCancel, String? confirmText}) {
    final theme = Style.of(context);
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
        backgroundColor: Colors.transparent,
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration:
                theme.cardDecoration.copyWith(color: theme.themeBgColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: theme.cardDecoration,
                      child: Icon(
                        icon,
                        color: theme.contrast.withAlpha(229),
                        size: 32,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.headlineMedium,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: theme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  spacing: 8,
                  children: [
                    if (onCancel != null)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              onCancel.call();
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              decoration: theme.cardDecoration,
                              child: Center(
                                child: Text(
                                  'Atcelt',
                                  style: GoogleFonts.poppins(
                                    color: theme.contrast.withAlpha(229),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onConfirm?.call();
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: theme.cardDecoration,
                            child: Center(
                              child: Text(
                                confirmText ?? 'Ok!',
                                style: GoogleFonts.poppins(
                                  color: theme.contrast.withAlpha(229),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
