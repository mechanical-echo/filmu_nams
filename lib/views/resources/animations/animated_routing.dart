import 'package:flutter/material.dart';

class AnimatedRouting extends PageRouteBuilder {
  final Widget page;

  AnimatedRouting({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(
                curve: Cubic(1, -0.20, 0, 1),
              ),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionDuration: const Duration(milliseconds: 1000),
        );
}
