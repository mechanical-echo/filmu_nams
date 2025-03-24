import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/color_context.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final colors = ColorContext.of(context);

    return Container(
      margin: const EdgeInsets.only(
        top: 75,
        left: 10,
        right: 10,
      ),
      width: width,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: colors.classicDecorationSharper,
              child: Row(
                spacing: 10,
                children: [
                  Icon(
                    Icons.movie_filter,
                    color: Colors.white,
                    size: 28,
                  ),
                  Text(
                    "Filmu Nams",
                    style: header2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: colors.classicDecorationWhiteSharper,
              child: Row(
                spacing: 10,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: colors.color001,
                  ),
                  Text(
                    DateFormat('E\ndd.MM.', 'lv').format(DateTime.now()),
                    style: colors.bodySmallThemeColor,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
