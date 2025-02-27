import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylizedTab extends StatefulWidget {
  const StylizedTab({
    super.key,
    required this.title,
    required this.isActive,
    required this.isLast,
    required this.index,
    required this.onTap,
  });

  final String title;
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white12,
                  width: 5,
                ),
              ),
              borderRadius: widget.isLast
                  ? BorderRadius.only(topRight: Radius.circular(20))
                  : (widget.index == 0
                      ? BorderRadius.only(topLeft: Radius.circular(20))
                      : BorderRadius.zero),
            ),
            child: Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: widget.isActive
                    ? Colors.white
                    : Theme.of(context)
                        .bottomNavigationBarTheme
                        .unselectedItemColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
