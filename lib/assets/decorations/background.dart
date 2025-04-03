import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final colors = ColorContext.of(context);

    return Stack(
      children: [
        // Main gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.black.withOpacity(0.95),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
        ),

        // Subtle pattern overlay
        CustomPaint(
          size: Size(width, height),
          painter: GridPainter(
            color: Colors.white.withOpacity(0.03),
            strokeWidth: 1,
            spacing: 30,
          ),
        ),

        // Radial gradient for depth
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Content
        child,
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
