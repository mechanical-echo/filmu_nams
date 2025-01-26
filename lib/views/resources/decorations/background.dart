import 'package:flutter/material.dart';
import 'package:pattern_background/pattern_background.dart';

class Background extends StatelessWidget {
  const Background({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Gradients
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 34, 5, 6), Colors.black],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter)),
        ),

        // Melnie punkti
        CustomPaint(
            size: Size(width, height),
            painter: DotPainter(
              dotColor: Colors.black,
              dotRadius: 4,
              spacing: 10,
            )),
        child
      ],
    );
  }
}
