import 'package:filmu_nams/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/color_context.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.movie_filter,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Filmu Nams",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('E\ndd.MM.', 'lv').format(DateTime.now()),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
