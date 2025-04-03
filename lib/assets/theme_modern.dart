import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modern color palette
Color primaryDark = const Color(0xFF121212);
Color primaryLight = const Color(0xFFF5F5F7);
Color accentRed = const Color(0xFFE50914);
Color accentGold = const Color(0xFFFFD700);
Color neutralGray = const Color(0xFF757575);
Color darkGray = const Color(0xFF333333);
Color lightGray = const Color(0xFFE0E0E0);
Color almostWhite = const Color(0xFFF8F8F8);
Color cardBackground = const Color(0xFF212121);

// Typography
TextStyle displayLarge = GoogleFonts.montserrat(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
);

TextStyle displayMedium = GoogleFonts.montserrat(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
);

TextStyle displaySmall = GoogleFonts.montserrat(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

TextStyle headlineLarge = GoogleFonts.montserrat(
  fontSize: 22,
  fontWeight: FontWeight.w600,
);

TextStyle headlineMedium = GoogleFonts.montserrat(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

TextStyle titleLarge = GoogleFonts.montserrat(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.15,
);

TextStyle titleMedium = GoogleFonts.montserrat(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.15,
);

TextStyle titleSmall = GoogleFonts.montserrat(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
);

TextStyle labelLarge = GoogleFonts.montserrat(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.1,
);

TextStyle labelMedium = GoogleFonts.montserrat(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
);

TextStyle labelSmall = GoogleFonts.montserrat(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
);

TextStyle bodyLarge = GoogleFonts.roboto(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.5,
);

TextStyle bodyMedium = GoogleFonts.roboto(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.25,
);

TextStyle bodySmall = GoogleFonts.roboto(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.4,
);

// Modern theme for dark mode
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: accentRed,
    onPrimary: Colors.white,
    primaryContainer: accentRed.withOpacity(0.8),
    onPrimaryContainer: Colors.white,
    secondary: accentGold,
    onSecondary: primaryDark,
    secondaryContainer: accentGold.withOpacity(0.8),
    onSecondaryContainer: primaryDark,
    tertiary: neutralGray,
    onTertiary: Colors.white,
    tertiaryContainer: neutralGray.withOpacity(0.2),
    onTertiaryContainer: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    errorContainer: Colors.redAccent.withOpacity(0.2),
    onErrorContainer: Colors.white,
    background: primaryDark,
    onBackground: Colors.white,
    surface: cardBackground,
    onSurface: Colors.white,
    surfaceVariant: darkGray,
    onSurfaceVariant: Colors.white70,
    outline: neutralGray,
    shadow: Colors.black,
    inverseSurface: Colors.white,
    onInverseSurface: primaryDark,
    inversePrimary: accentRed,
    surfaceTint: cardBackground,
  ),
  textTheme: TextTheme(
    displayLarge: displayLarge.copyWith(color: Colors.white),
    displayMedium: displayMedium.copyWith(color: Colors.white),
    displaySmall: displaySmall.copyWith(color: Colors.white),
    headlineLarge: headlineLarge.copyWith(color: Colors.white),
    headlineMedium: headlineMedium.copyWith(color: Colors.white),
    titleLarge: titleLarge.copyWith(color: Colors.white),
    titleMedium: titleMedium.copyWith(color: Colors.white),
    titleSmall: titleSmall.copyWith(color: Colors.white),
    labelLarge: labelLarge.copyWith(color: Colors.white),
    labelMedium: labelMedium.copyWith(color: Colors.white),
    labelSmall: labelSmall.copyWith(color: Colors.white),
    bodyLarge: bodyLarge.copyWith(color: Colors.white),
    bodyMedium: bodyMedium.copyWith(color: Colors.white),
    bodySmall: bodySmall.copyWith(color: Colors.white),
  ),
  scaffoldBackgroundColor: primaryDark,
  cardTheme: CardTheme(
    color: cardBackground,
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: primaryDark,
    selectedItemColor: accentRed,
    unselectedItemColor: neutralGray,
    type: BottomNavigationBarType.fixed,
    elevation: 10,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: primaryDark,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: titleLarge.copyWith(color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkGray,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      borderSide: BorderSide(color: accentRed, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.redAccent, width: 1),
    ),
    hintStyle: bodyMedium.copyWith(color: Colors.white54),
    labelStyle: labelLarge.copyWith(color: Colors.white),
    floatingLabelStyle: labelLarge.copyWith(color: accentRed),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentRed,
      foregroundColor: Colors.white,
      textStyle: labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      textStyle: labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide(color: accentRed, width: 1),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: accentRed,
      textStyle: labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: darkGray,
    disabledColor: darkGray.withOpacity(0.5),
    selectedColor: accentRed,
    secondarySelectedColor: accentGold,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: labelMedium.copyWith(color: Colors.white),
    secondaryLabelStyle: labelMedium.copyWith(color: Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: neutralGray.withOpacity(0.3),
    thickness: 1,
    space: 24,
  ),
  iconTheme: IconThemeData(
    color: Colors.white,
    size: 24,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: darkGray,
    contentTextStyle: bodyMedium.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
  ),
);

// Modern theme for light mode
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: accentRed,
    onPrimary: Colors.white,
    primaryContainer: accentRed.withOpacity(0.1),
    onPrimaryContainer: accentRed,
    secondary: accentGold,
    onSecondary: Colors.black,
    secondaryContainer: accentGold.withOpacity(0.1),
    onSecondaryContainer: Colors.black,
    tertiary: neutralGray,
    onTertiary: Colors.white,
    tertiaryContainer: neutralGray.withOpacity(0.1),
    onTertiaryContainer: neutralGray,
    error: Colors.redAccent,
    onError: Colors.white,
    errorContainer: Colors.redAccent.withOpacity(0.1),
    onErrorContainer: Colors.redAccent,
    background: primaryLight,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    surfaceVariant: lightGray,
    onSurfaceVariant: darkGray,
    outline: neutralGray,
    shadow: Colors.black.withOpacity(0.1),
    inverseSurface: darkGray,
    onInverseSurface: Colors.white,
    inversePrimary: accentRed,
    surfaceTint: Colors.white,
  ),
  textTheme: TextTheme(
    displayLarge: displayLarge.copyWith(color: Colors.black),
    displayMedium: displayMedium.copyWith(color: Colors.black),
    displaySmall: displaySmall.copyWith(color: Colors.black),
    headlineLarge: headlineLarge.copyWith(color: Colors.black),
    headlineMedium: headlineMedium.copyWith(color: Colors.black),
    titleLarge: titleLarge.copyWith(color: Colors.black),
    titleMedium: titleMedium.copyWith(color: Colors.black),
    titleSmall: titleSmall.copyWith(color: Colors.black),
    labelLarge: labelLarge.copyWith(color: Colors.black),
    labelMedium: labelMedium.copyWith(color: Colors.black),
    labelSmall: labelSmall.copyWith(color: Colors.black),
    bodyLarge: bodyLarge.copyWith(color: Colors.black),
    bodyMedium: bodyMedium.copyWith(color: Colors.black),
    bodySmall: bodySmall.copyWith(color: Colors.black),
  ),
  scaffoldBackgroundColor: primaryLight,
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: accentRed,
    unselectedItemColor: neutralGray,
    type: BottomNavigationBarType.fixed,
    elevation: 10,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: titleLarge.copyWith(color: Colors.black),
    iconTheme: IconThemeData(color: accentRed),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightGray.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      borderSide: BorderSide(color: accentRed, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.redAccent, width: 1),
    ),
    hintStyle: bodyMedium.copyWith(color: neutralGray),
    labelStyle: labelLarge.copyWith(color: darkGray),
    floatingLabelStyle: labelLarge.copyWith(color: accentRed),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentRed,
      foregroundColor: Colors.white,
      textStyle: labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: accentRed,
      textStyle: labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide(color: accentRed, width: 1),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: accentRed,
      textStyle: labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: lightGray,
    disabledColor: lightGray.withOpacity(0.5),
    selectedColor: accentRed,
    secondarySelectedColor: accentGold,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: labelMedium.copyWith(color: darkGray),
    secondaryLabelStyle: labelMedium.copyWith(color: Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: neutralGray.withOpacity(0.2),
    thickness: 1,
    space: 24,
  ),
  iconTheme: IconThemeData(
    color: darkGray,
    size: 24,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: darkGray,
    contentTextStyle: bodyMedium.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
  ),
);

// Shadows for elevation
List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 4),
  ),
];

List<BoxShadow> elevatedShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 12,
    offset: const Offset(0, 6),
  ),
];

// Decorations
BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).cardTheme.color,
  borderRadius: BorderRadius.circular(16),
  boxShadow: cardShadow,
);

BoxDecoration gradientCardDecoration(BuildContext context) => BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primary.withOpacity(0.7),
    ],
  ),
  borderRadius: BorderRadius.circular(16),
  boxShadow: cardShadow,
);

BoxDecoration ticketDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).cardTheme.color,
  borderRadius: BorderRadius.circular(16),
  boxShadow: cardShadow,
);

// Button Styles
ButtonStyle primaryButtonStyle(BuildContext context) => ElevatedButton.styleFrom(
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  textStyle: labelLarge,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);

ButtonStyle outlinedButtonStyle(BuildContext context) => OutlinedButton.styleFrom(
  foregroundColor: Theme.of(context).colorScheme.primary,
  side: BorderSide(color: Theme.of(context).colorScheme.primary),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  textStyle: labelLarge,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);

ButtonStyle textButtonStyle(BuildContext context) => TextButton.styleFrom(
  foregroundColor: Theme.of(context).colorScheme.primary,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  textStyle: labelLarge.copyWith(
    decoration: TextDecoration.underline,
    decorationColor: Theme.of(context).colorScheme.primary,
  ),
);

// Helper method to get theme-aware text styles
extension TextStyleExtension on TextTheme {
  TextStyle get movieTitle => titleLarge.copyWith(
    fontWeight: FontWeight.bold,
  );
  
  TextStyle get movieInfo => bodyMedium;
  
  TextStyle get movieDescription => bodySmall;
  
  TextStyle get ticketLabel => labelMedium.copyWith(
    fontWeight: FontWeight.bold,
  );
  
  TextStyle get ticketValue => bodyMedium;
  
  TextStyle get profileName => titleMedium.copyWith(
    fontWeight: FontWeight.bold,
  );
  
  TextStyle get appBarTitle => titleLarge.copyWith(
    fontWeight: FontWeight.bold,
  );
}