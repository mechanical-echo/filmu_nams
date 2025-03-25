import 'package:filmu_nams/providers/color_context.dart';
import 'package:filmu_nams/views/admin/dashboard/widgets/stylized_button.dart';
import 'package:flutter/material.dart';

class StylizedDialog {
  static void alert(BuildContext context, String title, String content) {
    final colors = ColorContext.of(context);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        titleTextStyle: colors.header2ThemeColor,
        contentTextStyle: colors.bodyMedium,
        actions: [
          StylizedButton(
            action: () {
              Navigator.of(context).pop();
            },
            title: 'Ok!',
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
