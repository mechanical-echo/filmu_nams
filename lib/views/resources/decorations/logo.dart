import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      title: Container(
          clipBehavior: Clip.none,
          child: Column(
            children: [
              Container(height: 75), //tukšā vieta virs logotipa

              // Josla ar logotipu
              AppBar(
                clipBehavior: Clip.none,
                title: Row(
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SvgPicture.asset(
                        "assets/Logo.svg",
                        height: 120,
                      ),
                    ),

                    // Šodienas datums
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      child: BorderedText(
                        strokeWidth: 5.0,
                        strokeColor: Colors.black,
                        child: Text(
                          DateFormat('E dd.MM.', 'lv').format(DateTime.now()),
                          style: GoogleFonts.kodchasan(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                centerTitle: false,
              )
            ],
          )),
    );
  }
}
