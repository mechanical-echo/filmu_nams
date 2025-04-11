import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/color_context.dart';

class StylizedTabTitle {
  final bool isIcon;
  final dynamic value;

  const StylizedTabTitle({required this.isIcon, required this.value});

  const StylizedTabTitle.text(String text)
      : value = text,
        isIcon = false;

  const StylizedTabTitle.icon(IconData icon)
      : value = icon,
        isIcon = true;
}

class StylizedTab extends StatefulWidget {
  const StylizedTab({
    super.key,
    required this.title,
    required this.isActive,
    required this.isLast,
    required this.index,
    required this.onTap,
    this.upsideDown = false,
    this.fontSize = 24,
  });

  final bool upsideDown;
  final double fontSize;
  final StylizedTabTitle title;
  final bool isActive;
  final bool isLast;
  final int index;

  final VoidCallback onTap;

  @override
  State<StylizedTab> createState() => _StylizedTabState();
}

class _StylizedTabState extends State<StylizedTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation = ColorTween(
      begin: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      end: Theme.of(context).focusColor,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(StylizedTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ContextTheme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: 45,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white12,
                  width: 5,
                ),
              ),
              borderRadius: borderRadius(),
            ),
            child: widget.title.isIcon
                ? Icon(
                    widget.title.value as IconData,
                    color: widget.isActive
                        ? Colors.white
                        : colors.onSurfaceVariant,
                    size: widget.fontSize + 9,
                  )
                : Text(
                    widget.title.value as String,
                    style: GoogleFonts.poppins(
                      color: widget.isActive
                          ? Colors.white
                          : Theme.of(context)
                              .bottomNavigationBarTheme
                              .unselectedItemColor,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
          );
        },
      ),
    );
  }

  BorderRadius borderRadius() {
    if (widget.isLast) {
      return widget.upsideDown
          ? BorderRadius.only(bottomRight: Radius.circular(20))
          : BorderRadius.only(topRight: Radius.circular(20));
    } else if (widget.index == 0 && !widget.isLast) {
      return widget.upsideDown
          ? BorderRadius.only(bottomLeft: Radius.circular(20))
          : BorderRadius.only(topLeft: Radius.circular(20));
    }

    return BorderRadius.circular(0);
  }
}
