import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylizedTableHeaderCell extends StatelessWidget {
  const StylizedTableHeaderCell({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
