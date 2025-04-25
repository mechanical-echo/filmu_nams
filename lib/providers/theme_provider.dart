import 'package:filmu_nams/assets/decorations/background.dart';
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
          seedColor: const Color(0xFF8E1616),
          brightness: Brightness.dark,
        );
      case AppTheme.blueDark:
        return _buildTheme(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        );
      case AppTheme.redLight:
        return _buildTheme(
          seedColor: const Color(0xFF8E1616),
          brightness: Brightness.light,
        );
      case AppTheme.blueLight:
        return _buildTheme(
          seedColor: const Color(0xFF1E88E5),
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
          color: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616),
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616).withAlpha(185),
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616).withAlpha(185),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616),
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616),
        ),
      ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF212121) : Color(0xFFEEEEEE),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Color(0xFFEEEEEE),
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconSize: 20,
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 15),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? const Color(0xFF212121) : Color(0xFFEEEEEE),
        indicatorColor: seedColor,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        selectedIconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: isDark ? Color(0xFFEEEEEE) : Colors.grey[600],
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : Color(0xFFEEEEEE),
        selectedItemColor: seedColor,
        unselectedItemColor: isDark ? Colors.grey : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121212) : Color(0xFFEEEEEE),
        foregroundColor: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        iconColor: Color(0xFFEEEEEE).withOpacity(0.7),
        hintStyle: GoogleFonts.poppins(
          color: Color(0xFFEEEEEE).withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Color(0xFFEEEEEE).withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Color(0xFFEEEEEE).withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Color(0xFFEEEEEE).withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Color(0xFFEEEEEE).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: Color(0xFFEEEEEE),
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
        color: isDark ? Color(0xFFEEEEEE) : Colors.grey[300],
        thickness: 1,
        space: 24,
      ),
      iconTheme: IconThemeData(
        color: isDark ? Color(0xFFEEEEEE) : seedColor.darker(0.05),
        size: 24,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF212121) : Color(0xFFEEEEEE),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDark ? const Color(0xFF212121) : Color(0xFFEEEEEE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF333333) : Colors.grey[800],
        contentTextStyle: GoogleFonts.poppins(
          color: Color(0xFFEEEEEE),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF212121) : Color(0xFFEEEEEE),
        selectedColor: seedColor,
        secondarySelectedColor: seedColor.withOpacity(0.5),
        disabledColor: Colors.grey[400],
        labelStyle: GoogleFonts.poppins(
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616).withAlpha(185),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF212121) : Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          color: isDark ? Color(0xFFEEEEEE) : Color(0xFF1D1616),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
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

  bool get isDark =>
      _currentTheme == AppTheme.redDark || _currentTheme == AppTheme.blueDark;

  Color get primary => _currentTheme == AppTheme.redDark
      ? Color.fromARGB(255, 168, 38, 43)
      : const Color.fromARGB(255, 102, 177, 243);
}
