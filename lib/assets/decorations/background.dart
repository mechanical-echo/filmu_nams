import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';

class Background extends StatefulWidget {
  const Background({super.key, required this.child});

  final Widget child;

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation1 = ColorTween(
      begin: Colors.white.withOpacity(0.15),
      end: Colors.white.withOpacity(0.3),
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final theme = ContextTheme.of(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.isDark
                  ? [
                      Colors.black,
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.9)
                    ]
                  : [
                      Colors.grey[200]!,
                      Colors.grey[200]!.withOpacity(0.95),
                      Colors.grey[200]!.withOpacity(0.9),
                    ],
            ),
          ),
        ),
        CustomPaint(
          size: Size(width, height),
          painter: GridPainter(
            color: theme.isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.black.withOpacity(0.075),
            strokeWidth: 1,
            spacing: 30,
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1,
                  colors: [
                    _colorAnimation1.value!,
                    _colorAnimation2.value!,
                  ],
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double spacing;

  GridPainter({
    required this.color,
    required this.strokeWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.spacing != spacing;
  }
}

extension ColorExtension on Color {
  Color darker([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighter([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
