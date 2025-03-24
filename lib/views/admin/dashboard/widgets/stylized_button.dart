import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';

class StylizedButton extends StatefulWidget {
  const StylizedButton({
    super.key,
    required this.action,
    required this.title,
    this.icon,
    this.textStyle,
    this.iconSize = 25,
    this.horizontalPadding = 55,
  });

  final Function action;
  final String title;
  final IconData? icon;
  final TextStyle? textStyle;
  final double iconSize;
  final double horizontalPadding;

  @override
  State<StylizedButton> createState() => _StylizedButtonState();
}

class _StylizedButtonState extends State<StylizedButton> {
  late BoxDecoration decoration;
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = ColorContext.of(context);

    // Update decoration based on state
    if (isPressed) {
      decoration = colors.classicDecorationWhiteSharperActive;
    } else if (isHovered) {
      decoration = colors.classicDecorationWhiteSharperHover;
    } else {
      decoration = colors.classicDecorationWhiteSharper;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => isHovered = true),
      onExit: (event) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (details) => setState(() => isPressed = true),
        onTapUp: (details) {
          setState(() => isPressed = false);
          widget.action();
        },
        onTapCancel: () => setState(() => isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          decoration: decoration,
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding,
            vertical: 5,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              if (widget.icon != null)
                Positioned(
                  left: -40,
                  child: Icon(
                      widget.icon,
                      color: colors.color001,
                      size: widget.iconSize
                  ),
                ),
              Center(
                child: Text(
                  widget.title,
                  style: widget.textStyle ?? colors.bodyLargeThemeColor,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}