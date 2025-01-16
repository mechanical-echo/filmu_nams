import 'package:flutter/material.dart';

ThemeData theme = ThemeData(
  primaryColor: Color.fromARGB(255, 123, 29, 29),
  focusColor: Color.fromARGB(255, 119, 41, 32),
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
);
