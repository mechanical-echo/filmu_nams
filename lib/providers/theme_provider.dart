import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  redDark,
  blueDark,
  redLight,
  blueLight,
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

  ThemeData get currentTheme {
    switch (_currentTheme) {
      case AppTheme.redDark:
        return _buildTheme(
          seedColor: const Color(0xFFE50914), // Netflix red
          brightness: Brightness.dark,
        );
      case AppTheme.blueDark:
        return _buildTheme(
          seedColor: const Color(0xFF1E88E5), // Material blue
          brightness: Brightness.dark,
        );
      case AppTheme.redLight:
        return _buildTheme(
          seedColor: const Color(0xFFE50914), // Netflix red
          brightness: Brightness.light,
        );
      case AppTheme.blueLight:
        return _buildTheme(
          seedColor: const Color(0xFF1E88E5), // Material blue
          brightness: Brightness.light,
        );
    }
  }

  ThemeData _buildTheme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF212121) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        selectedItemColor: seedColor,
        unselectedItemColor: isDark ? Colors.grey : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF333333) : Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seedColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        hintStyle: GoogleFonts.poppins(
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
        labelStyle: GoogleFonts.poppins(
          color: isDark ? Colors.white : Colors.black,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          color: seedColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: seedColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: seedColor, width: 1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: seedColor,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white24 : Colors.grey[300],
        thickness: 1,
        space: 24,
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.black,
        size: 24,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF212121) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDark ? const Color(0xFF212121) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF333333) : Colors.grey[800],
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
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
