import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromARGB(255, 87, 33, 27),
      primary: Color.fromARGB(255, 123, 29, 29),
      primaryContainer: Color.fromARGB(255, 123, 29, 29),
      secondary: Color.fromARGB(255, 123, 29, 29),
      secondaryContainer: Color.fromARGB(255, 87, 33, 27),
      surface: Color.fromARGB(255, 123, 29, 29),
      onSurface: Colors.white,
    ),
    primarySwatch: Colors.red,
    primaryColor: Color.fromARGB(255, 123, 29, 29),
    focusColor: Color.fromARGB(255, 119, 41, 32),
    cardColor: Color.fromARGB(255, 87, 33, 27),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 102, 30, 23),
        unselectedItemColor: Color.fromARGB(255, 178, 104, 96),
        selectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            overflow: TextOverflow.visible,
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold)),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 123, 29, 29),
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Color.fromARGB(255, 123, 29, 29),
      cursorColor: Color.fromARGB(255, 123, 123, 123),
      selectionHandleColor: Color.fromARGB(255, 123, 29, 29),
    ),
    dialogBackgroundColor: Color.fromARGB(255, 44, 39, 39),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        )),
        fixedSize: WidgetStatePropertyAll(Size(272, 50)),
        backgroundColor:
            WidgetStatePropertyAll(Color.fromARGB(255, 151, 50, 39)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 151, 50, 39),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 6),
        ),
        overlayColor: WidgetStatePropertyAll(Color.fromARGB(50, 151, 50, 39)),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(
            fontSize: 15,
            decoration: TextDecoration.underline,
            decorationColor: Color.fromARGB(255, 151, 50, 39),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      fillColor: Color.fromARGB(255, 64, 62, 62),
      filled: true,
      floatingLabelStyle:
          GoogleFonts.poppins(color: Colors.white, fontSize: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 4),
      ),
      hintStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w200,
          color: Color.fromARGB(255, 123, 123, 123)),
      suffixIconColor: Color.fromARGB(255, 123, 123, 123),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Color.fromARGB(255, 123, 123, 123), width: 0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Color.fromARGB(255, 123, 123, 123), width: 1),
      ),
    ),
    dividerTheme: DividerThemeData(
      space: 0,
      thickness: 2,
      indent: 20,
      endIndent: 20,
      color: Color.fromARGB(255, 119, 41, 32),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              13,
            ),
          ),
        ),
        iconColor: WidgetStatePropertyAll(Colors.white),
      ),
    ));
