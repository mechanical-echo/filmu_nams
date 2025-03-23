import 'package:filmu_nams/assets/theme.dart';
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
  BoxDecoration decoration = classicDecorationWhiteSharper;

  void onHover() {
    setState(() {
      decoration = classicDecorationWhiteSharperHover;
    });
  }

  void onHoverEnd() {
    setState(() {
      decoration = classicDecorationWhiteSharper;
    });
  }

  void onTap() {
    setState(() {
      decoration = classicDecorationWhiteSharperActive;
      widget.action();
    });
  }

  void onRelease() {
    setState(() {
      decoration = classicDecorationWhiteSharper;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => onHover(),
      onExit: (event) => onHoverEnd(),
      child: GestureDetector(
        onTapDown: (details) => onTap(),
        onTapUp: (details) => onRelease(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 50),
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
                  child:
                      Icon(widget.icon, color: red001, size: widget.iconSize),
                ),
              Center(
                child: Text(
                  widget.title,
                  style: widget.textStyle ?? bodyLargeRed,
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
