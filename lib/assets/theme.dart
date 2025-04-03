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
    brightness: Brightness.dark,
  ),
  primarySwatch: Colors.red,
  primaryColor: Color.fromARGB(255, 102, 30, 23),
  focusColor: Color.fromARGB(255, 119, 41, 32),
  cardColor: Color.fromARGB(255, 87, 33, 27),
  disabledColor: Color.fromARGB(255, 111, 36, 29),
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
    foregroundColor: Colors.white,
  ),
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: Color.fromARGB(255, 123, 29, 29),
    cursorColor: Color.fromARGB(255, 123, 123, 123),
    selectionHandleColor: Color.fromARGB(255, 123, 29, 29),
  ),
  dialogBackgroundColor: Color.fromARGB(255, 44, 39, 39),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      textStyle: bodyLarge,
      padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
      backgroundColor: classicDecoration.color,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
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
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      side: WidgetStatePropertyAll(
        BorderSide(
          color: Colors.white,
          width: 2,
        ),
      ),
      iconColor: WidgetStatePropertyAll(Colors.white),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      foregroundColor: Colors.white,
    ),
  ),
);

Color smokeyWhite = Color.fromARGB(255, 248, 237, 237);
Color red001 = Color.fromARGB(255, 102, 30, 23);
Color red002 = Color.fromARGB(255, 119, 41, 32);
Color red003 = Color.fromARGB(255, 178, 104, 96);

FilledButtonThemeData bigRed = FilledButtonThemeData(
  style: FilledButton.styleFrom(
    textStyle: bodyLarge,
    padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
    backgroundColor: classicDecoration.color,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
);

ButtonStyle mediumWhite = FilledButton.styleFrom(
  textStyle: bodySmallRed,
  foregroundColor: red001,
  backgroundColor: classicDecorationWhite.color,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5),
  ),
);

ButtonStyle smallWhite = FilledButton.styleFrom(
  textStyle: bodySmallRed,
  foregroundColor: red001,
  backgroundColor: classicDecorationWhite.color,
  fixedSize: Size(double.infinity, 30),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5),
  ),
);

TextStyle bodySmall = GoogleFonts.poppins(
  color: Colors.white,
  fontSize: 13,
  fontWeight: FontWeight.w600,
);

TextStyle bodySmallRed = GoogleFonts.poppins(
  color: red001,
  fontSize: 13,
  fontWeight: FontWeight.w600,
);

TextStyle bodyMedium = GoogleFonts.poppins(
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.w600,
);

TextStyle bodyMediumRed = GoogleFonts.poppins(
  color: red001,
  fontSize: 17,
  fontWeight: FontWeight.w700,
);

TextStyle bodyLarge = GoogleFonts.poppins(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.w800,
);

TextStyle bodyLargeRed = GoogleFonts.poppins(
  color: red001,
  fontSize: 20,
  fontWeight: FontWeight.w800,
);

TextStyle header1 = GoogleFonts.poppins(
  color: Colors.white,
  fontSize: 30,
  fontWeight: FontWeight.w800,
);

TextStyle header1Red = GoogleFonts.poppins(
  color: red001,
  fontSize: 30,
  fontWeight: FontWeight.w800,
);

TextStyle header2 = GoogleFonts.poppins(
  color: Colors.white,
  fontSize: 26,
  fontWeight: FontWeight.w800,
);

TextStyle header2Red = GoogleFonts.poppins(
  color: red001,
  fontSize: 26,
  fontWeight: FontWeight.w800,
);

Border bottomBorder = Border(
  bottom: BorderSide(
    color: Colors.white12,
    width: 5,
  ),
);

Border bottomBorderDark = Border(
  bottom: BorderSide(
    color: red001.withAlpha(100),
    width: 5,
  ),
);

List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Colors.black.withAlpha(50),
    blurRadius: 10,
    offset: Offset(0, 17),
  )
];

BoxDecoration classicDecoration = BoxDecoration(
  color: red002,
  boxShadow: cardShadow,
  border: bottomBorder,
  borderRadius: BorderRadius.circular(15),
);

BoxDecoration classicDecorationWhite = BoxDecoration(
  color: smokeyWhite,
  boxShadow: cardShadow,
  border: bottomBorderDark,
  borderRadius: BorderRadius.circular(15),
);

BoxDecoration classicDecorationDark = BoxDecoration(
  color: red001,
  boxShadow: cardShadow,
  border: bottomBorder,
  borderRadius: BorderRadius.circular(15),
);

BoxDecoration classicDecorationSharp = BoxDecoration(
  color: red002,
  boxShadow: cardShadow,
  border: bottomBorder,
  borderRadius: BorderRadius.circular(8),
);

BoxDecoration classicDecorationSharper = BoxDecoration(
  color: red002,
  boxShadow: cardShadow,
  border: bottomBorder,
  borderRadius: BorderRadius.circular(5),
);

BoxDecoration classicDecorationWhiteSharper = BoxDecoration(
  color: smokeyWhite,
  boxShadow: cardShadow,
  border: bottomBorderDark,
  borderRadius: BorderRadius.circular(5),
);

BoxDecoration classicDecorationWhiteSharperHover = BoxDecoration(
  color: smokeyWhite.withAlpha(200),
  boxShadow: cardShadow,
  border: bottomBorderDark,
  borderRadius: BorderRadius.circular(5),
);

BoxDecoration classicDecorationWhiteSharperActive = BoxDecoration(
  color: smokeyWhite.withAlpha(150),
  boxShadow: cardShadow,
  border: bottomBorderDark,
  borderRadius: BorderRadius.circular(5),
);

BoxDecoration classicDecorationDarkSharper = BoxDecoration(
  color: red001,
  boxShadow: cardShadow,
  border: bottomBorder,
  borderRadius: BorderRadius.circular(5),
);

BoxDecoration darkDecorationSharper = BoxDecoration(
  color: Colors.black26,
  borderRadius: BorderRadius.circular(5),
);

BoxDecoration mediumDarkDecorationSharper = BoxDecoration(
  color: Colors.black12,
  borderRadius: BorderRadius.circular(5),
);

BoxDecoration darkDecoration = BoxDecoration(
  color: Colors.black26,
  borderRadius: BorderRadius.circular(15),
);
