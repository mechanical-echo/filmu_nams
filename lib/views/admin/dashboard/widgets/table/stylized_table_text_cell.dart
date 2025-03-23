import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StylizedTableTextCell extends StatelessWidget {
  const StylizedTableTextCell({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w200,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
