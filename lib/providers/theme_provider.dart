import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  redDark,
  redLight,
  blueDark,
  blueLight,
}

class ThemeColors {
  final Color color001;
  final Color color002;
  final Color color003;
  final Color smokeyWhite;
  final bool isLightTheme;

  const ThemeColors({
    required this.color001,
    required this.color002,
    required this.color003,
    required this.smokeyWhite,
    this.isLightTheme = false,
  });
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  late SharedPreferences _prefs;
  AppTheme _currentTheme = AppTheme.redDark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _currentTheme = AppTheme.values.firstWhere(
        (theme) => theme.toString() == savedTheme,
        orElse: () => AppTheme.redDark,
      );
      notifyListeners();
    }
  }

  Future<void> _saveTheme(AppTheme theme) async {
    await _prefs.setString(_themeKey, theme.toString());
  }

  AppTheme get currentThemeEnum => _currentTheme;

  ThemeColors get colors {
    switch (_currentTheme) {
      case AppTheme.redDark:
        return const ThemeColors(
          color001: Color.fromARGB(255, 102, 30, 23),
          color002: Color.fromARGB(255, 119, 41, 32),
          color003: Color.fromARGB(255, 178, 104, 96),
          smokeyWhite: Color.fromARGB(255, 248, 237, 237),
          isLightTheme: false,
        );
      case AppTheme.blueDark:
        return const ThemeColors(
          color001: Color.fromARGB(255, 61, 90, 167),
          color002: Color.fromARGB(255, 82, 125, 212),
          color003: Color.fromARGB(255, 140, 178, 255),
          smokeyWhite: Color.fromARGB(255, 237, 241, 248),
          isLightTheme: false,
        );
      case AppTheme.redLight:
        return const ThemeColors(
          color001: Color.fromARGB(255, 102, 30, 23),
          color002: Color.fromARGB(255, 119, 41, 32),
          color003: Color.fromARGB(255, 178, 104, 96),
          smokeyWhite: Color.fromARGB(255, 248, 237, 237),
          isLightTheme: true,
        );
      case AppTheme.blueLight:
        return const ThemeColors(
          color001: Color.fromARGB(255, 61, 90, 167),
          color002: Color.fromARGB(255, 82, 125, 212),
          color003: Color.fromARGB(255, 140, 178, 255),
          smokeyWhite: Color.fromARGB(255, 237, 241, 248),
          isLightTheme: true,
        );
    }
  }

  TextStyle get bodySmall => GoogleFonts.poppins(
        color: colors.isLightTheme ? Colors.black87 : Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  TextStyle get bodySmallThemeColor => GoogleFonts.poppins(
        color: colors.color001,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  TextStyle get bodyMedium => GoogleFonts.poppins(
        color: colors.isLightTheme ? Colors.black87 : Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  TextStyle get bodyMediumThemeColor => GoogleFonts.poppins(
        color: colors.color001,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      );

  TextStyle get bodyLarge => GoogleFonts.poppins(
        color: colors.isLightTheme ? Colors.black87 : Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      );

  TextStyle get bodyLargeThemeColor => GoogleFonts.poppins(
        color: colors.color001,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      );

  TextStyle get header1 => GoogleFonts.poppins(
        color: colors.isLightTheme ? Colors.black87 : Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.w800,
      );

  TextStyle get header3 => GoogleFonts.poppins(
        color: colors.isLightTheme ? Colors.black87 : Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      );

  TextStyle get header1ThemeColor => GoogleFonts.poppins(
        color: colors.color001,
        fontSize: 30,
        fontWeight: FontWeight.w800,
      );

  TextStyle get header2 => GoogleFonts.poppins(
        color: colors.isLightTheme ? Colors.black87 : Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      );

  TextStyle get header2ThemeColor => GoogleFonts.poppins(
        color: colors.color001,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      );

  BoxDecoration get classicDecoration => BoxDecoration(
        color: colors.color002,
        boxShadow: cardShadow,
        border: bottomBorder,
        borderRadius: BorderRadius.circular(15),
      );

  BoxDecoration get classicDecorationWhite => BoxDecoration(
        color: colors.smokeyWhite,
        boxShadow: cardShadow,
        border: bottomBorderDark,
        borderRadius: BorderRadius.circular(15),
      );

  BoxDecoration get classicDecorationDark => BoxDecoration(
        color: colors.color001,
        boxShadow: cardShadow,
        border: bottomBorder,
        borderRadius: BorderRadius.circular(15),
      );

  BoxDecoration get classicDecorationSharp => BoxDecoration(
        color: colors.color002,
        boxShadow: cardShadow,
        border: bottomBorder,
        borderRadius: BorderRadius.circular(8),
      );

  BoxDecoration get classicDecorationSharper => BoxDecoration(
        color: colors.color002,
        boxShadow: cardShadow,
        border: bottomBorder,
        borderRadius: BorderRadius.circular(5),
      );

  BoxDecoration get classicDecorationWhiteSharper => BoxDecoration(
        color: colors.smokeyWhite,
        boxShadow: cardShadow,
        border: bottomBorderDark,
        borderRadius: BorderRadius.circular(5),
      );

  BoxDecoration get classicDecorationWhiteSharperHover => BoxDecoration(
        color: colors.smokeyWhite.withAlpha(200),
        boxShadow: cardShadow,
        border: bottomBorderDark,
        borderRadius: BorderRadius.circular(5),
      );

  BoxDecoration get classicDecorationWhiteSharperActive => BoxDecoration(
        color: colors.smokeyWhite.withAlpha(150),
        boxShadow: cardShadow,
        border: bottomBorderDark,
        borderRadius: BorderRadius.circular(5),
      );

  BoxDecoration get classicDecorationDarkSharper => BoxDecoration(
        color: colors.color001,
        boxShadow: cardShadow,
        border: bottomBorder,
        borderRadius: BorderRadius.circular(5),
      );

  BoxDecoration get darkDecorationSharper => BoxDecoration(
        color: colors.isLightTheme ? Colors.grey.shade200 : Colors.black26,
        borderRadius: BorderRadius.circular(5),
      );

  BoxDecoration get mediumDarkDecorationSharper => BoxDecoration(
        color: colors.isLightTheme ? Colors.grey.shade100 : Colors.black12,
        borderRadius: BorderRadius.circular(5),
      );

  BoxDecoration get darkDecoration => BoxDecoration(
        color: colors.isLightTheme ? Colors.grey.shade200 : Colors.black26,
        borderRadius: BorderRadius.circular(15),
      );

  Border get bottomBorder => Border(
        bottom: BorderSide(
          color: Colors.white12,
          width: 5,
        ),
      );

  Border get bottomBorderDark => Border(
        bottom: BorderSide(
          color: colors.color001.withAlpha(100),
          width: 5,
        ),
      );

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          blurRadius: 10,
          offset: const Offset(0, 17),
        )
      ];

  ThemeData get currentTheme {
    switch (_currentTheme) {
      case AppTheme.redDark:
        return _buildTheme(
          seedColor: const Color.fromARGB(255, 87, 33, 27),
          primary: const Color.fromARGB(255, 123, 29, 29),
          baseColor: colors.color001,
          buttonColor: colors.color002,
          accentColor: colors.color003,
        );
      case AppTheme.blueDark:
        return _buildTheme(
          seedColor: const Color.fromARGB(255, 27, 54, 87),
          primary: const Color.fromARGB(255, 29, 69, 123),
          baseColor: colors.color001,
          buttonColor: colors.color002,
          accentColor: colors.color003,
        );
      case AppTheme.redLight:
        return _buildTheme(
          seedColor: const Color.fromARGB(255, 87, 33, 27),
          primary: const Color.fromARGB(255, 123, 29, 29),
          baseColor: colors.color001,
          buttonColor: colors.color002,
          accentColor: colors.color003,
        );
      case AppTheme.blueLight:
        return _buildTheme(
          seedColor: const Color.fromARGB(255, 27, 54, 87),
          primary: const Color.fromARGB(255, 29, 69, 123),
          baseColor: colors.color001,
          buttonColor: colors.color002,
          accentColor: colors.color003,
        );
    }
  }

  ThemeData _buildTheme({
    required Color seedColor,
    required Color primary,
    required Color baseColor,
    required Color buttonColor,
    required Color accentColor,
  }) {
    final isLight = colors.isLightTheme;
    final backgroundColor =
        isLight ? Colors.white : const Color.fromARGB(255, 44, 39, 39);
    final textColor = isLight ? Colors.black87 : Colors.white;
    final inputFillColor = isLight ? Colors.grey.shade100 : Colors.black26;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        primary: primary,
        primaryContainer: primary,
        secondary: primary,
        secondaryContainer: seedColor,
        surface: primary,
        onSurface: textColor,
        brightness: isLight ? Brightness.light : Brightness.dark,
      ),
      primaryColor: baseColor,
      focusColor: buttonColor,
      cardColor: seedColor,
      disabledColor: buttonColor.withOpacity(0.8),
      scaffoldBackgroundColor: isLight ? Colors.grey.shade100 : Colors.black,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: baseColor,
          unselectedItemColor: accentColor,
          selectedItemColor: isLight ? Colors.white : Colors.white,
          selectedLabelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              overflow: TextOverflow.visible,
              fontFamily: "Roboto",
              fontWeight: FontWeight.bold)),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: isLight ? Colors.white : Colors.white,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: primary,
        cursorColor: const Color.fromARGB(255, 123, 123, 123),
        selectionHandleColor: primary,
      ),
      dialogBackgroundColor: backgroundColor,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: bodyLarge,
          padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
          backgroundColor: buttonColor,
          foregroundColor: isLight ? Colors.white : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(
            accentColor,
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 6),
          ),
          overlayColor: WidgetStatePropertyAll(accentColor.withOpacity(0.2)),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.poppins(
              fontSize: 15,
              decoration: TextDecoration.underline,
              decorationColor: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: inputFillColor,
        filled: true,
        floatingLabelStyle: GoogleFonts.poppins(color: textColor, fontSize: 20),
        labelStyle: GoogleFonts.poppins(color: textColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: primary, width: 4),
        ),
        hintStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w200,
            color: const Color.fromARGB(255, 123, 123, 123)),
        suffixIconColor: const Color.fromARGB(255, 123, 123, 123),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide:
              BorderSide(color: Color.fromARGB(255, 123, 123, 123), width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide:
              BorderSide(color: Color.fromARGB(255, 123, 123, 123), width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.smokeyWhite.withAlpha(100),
        indent: 0,
        endIndent: 0,
        space: 0,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(textColor),
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
          iconColor: WidgetStatePropertyAll(textColor),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          foregroundColor: textColor,
        ),
      ),
      iconTheme: IconThemeData(
        color: textColor,
      ),
    );
  }

  String getThemeName() {
    switch (_currentTheme) {
      case AppTheme.redDark:
        return 'Sarkana/tumša';
      case AppTheme.blueDark:
        return 'Zila/tumša';
      case AppTheme.redLight:
        return 'Sarkana/gaiša';
      case AppTheme.blueLight:
        return 'Zila/gaiša';
    }
  }

  void setTheme(AppTheme theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      _saveTheme(theme);
      notifyListeners();
    }
  }
}
