import 'package:filmu_nams/providers/color_context.dart';
import 'package:flutter/material.dart';
import 'package:pattern_background/pattern_background.dart';

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
        // Gradients
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: colors.isLightTheme
                      ? [
                          Colors.white,
                          Colors.white,
                        ]
                      : [
                          colors.color001.darker(),
                          Colors.black,
                        ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter)),
        ),

        // Melnie punkti
        CustomPaint(
            size: Size(width, height),
            painter: DotPainter(
              dotColor: colors.isLightTheme
                  ? Colors.black.withAlpha(9)
                  : Colors.black,
              dotRadius: 4,
              spacing: 10,
            )),
        child
      ],
    );
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
