import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/color_context.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final theme = ContextTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: width,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 25),
                  decoration: theme.cardDecoration,
                  child: Row(
                    spacing: 15,
                    children: [
                      Icon(
                        Icons.movie_filter,
                        color: theme.contrast.withAlpha(150),
                        size: 24,
                      ),
                      Text(
                        "Filmu Nams",
                        style: GoogleFonts.poppins(
                          color: theme.contrast.withAlpha(110),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: theme.cardDecoration,
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E dd.MM.', 'lv').format(DateTime.now()),
                  style: GoogleFonts.poppins(
                    color: theme.contrast.withAlpha(150),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                ),
                Icon(
                  Icons.calendar_month,
                  color: theme.contrast.withAlpha(150),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
