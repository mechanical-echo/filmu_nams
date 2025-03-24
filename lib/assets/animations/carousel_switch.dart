import 'package:flutter/material.dart';

enum CarouselSwitchDirection { left, right }

class CarouselSwitch extends StatelessWidget {
  const CarouselSwitch({
    super.key,
    required this.child,
    required this.direction,
    this.alignment = AlignmentDirectional.topCenter,
  });

  final Widget child;
  final CarouselSwitchDirection direction;
  final AlignmentDirectional alignment;

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
      duration: const Duration(milliseconds: 750),
      reverseDuration: const Duration(milliseconds: 500),
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: alignment,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isEntering = animation.isForwardOrCompleted;
        return SlideTransition(
          position: Tween<Offset>(
            begin: isEntering ? enteringOffset : outcomingOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Cubic(1, 0, 0, 1),
          )),
          child: child,
        );
      },
      child: child,
    );
  }
}
