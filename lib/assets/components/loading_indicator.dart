import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final EdgeInsets padding;
  final LoadingAnimationType type;

  const LoadingIndicator({
    super.key,
    this.size = 100,
    this.color,
    this.padding = const EdgeInsets.only(top: 65, bottom: 40),
    this.type = LoadingAnimationType.staggeredDotsWave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: _getLoadingAnimation(context),
    );
  }

  Widget _getLoadingAnimation(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).focusColor;

    switch (type) {
      case LoadingAnimationType.staggeredDotsWave:
        return LoadingAnimationWidget.staggeredDotsWave(
          size: size,
          color: effectiveColor,
        );
      case LoadingAnimationType.stretchedDots:
        return LoadingAnimationWidget.stretchedDots(
          size: size,
          color: effectiveColor,
        );
    }
  }
}

enum LoadingAnimationType {
  staggeredDotsWave,
  stretchedDots,
}
