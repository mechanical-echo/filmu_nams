import 'package:flutter/material.dart';

enum CarouselSwitchDirection { left, right }

class CarouselSwitch extends StatelessWidget {
  final Widget child;
  final CarouselSwitchDirection direction;

  const CarouselSwitch(
      {super.key, required this.child, required this.direction});

  @override
  Widget build(BuildContext context) {
    late Offset enteringOffset;
    late Offset outcomingOffset;

    enteringOffset = direction == CarouselSwitchDirection.left
        ? const Offset(-2.0, 0.0)
        : const Offset(2.0, 0.0);
    outcomingOffset = direction == CarouselSwitchDirection.left
        ? const Offset(2.0, 0.0)
        : const Offset(-2.0, 0.0);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isEntering = animation.isForwardOrCompleted;
        return SlideTransition(
          position: Tween<Offset>(
            begin: isEntering ? enteringOffset : outcomingOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      child: child,
    );
  }
}
