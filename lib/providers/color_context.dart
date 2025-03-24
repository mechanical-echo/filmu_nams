import 'package:flutter/material.dart';
import 'package:filmu_nams/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorContext extends InheritedWidget {
  final ThemeProvider themeProvider;

  const ColorContext({
    super.key,
    required this.themeProvider,
    required super.child,
  });

  @override
  bool updateShouldNotify(ColorContext oldWidget) {
    return themeProvider != oldWidget.themeProvider;
  }

  static ColorContext of(BuildContext context) {
    final ColorContext? result =
        context.dependOnInheritedWidgetOfExactType<ColorContext>();
    assert(result != null, 'No ColorContext found in context');
    return result!;
  }

  Color get color001 => themeProvider.colors.color001;
  Color get color002 => themeProvider.colors.color002;
  Color get color003 => themeProvider.colors.color003;
  Color get smokeyWhite => themeProvider.colors.smokeyWhite;
  bool get isLightTheme => themeProvider.colors.isLightTheme;

  Color textColorFor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();

    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }

  TextStyle bodySmallFor(Color backgroundColor) => GoogleFonts.poppins(
        color: textColorFor(backgroundColor),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  TextStyle bodyMediumFor(Color backgroundColor) => GoogleFonts.poppins(
        color: textColorFor(backgroundColor),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  TextStyle bodyLargeFor(Color backgroundColor) => GoogleFonts.poppins(
        color: textColorFor(backgroundColor),
        fontSize: 20,
        fontWeight: FontWeight.w800,
      );

  TextStyle header1For(Color backgroundColor) => GoogleFonts.poppins(
        color: textColorFor(backgroundColor),
        fontSize: 30,
        fontWeight: FontWeight.w800,
      );

  TextStyle header2For(Color backgroundColor) => GoogleFonts.poppins(
        color: textColorFor(backgroundColor),
        fontSize: 26,
        fontWeight: FontWeight.w800,
      );

  TextStyle get bodySmall => themeProvider.bodySmall;
  TextStyle get bodySmallThemeColor => themeProvider.bodySmallThemeColor;
  TextStyle get bodyMedium => themeProvider.bodyMedium;
  TextStyle get bodyMediumThemeColor => themeProvider.bodyMediumThemeColor;
  TextStyle get bodyLarge => themeProvider.bodyLarge;
  TextStyle get bodyLargeThemeColor => themeProvider.bodyLargeThemeColor;
  TextStyle get header1 => themeProvider.header1;
  TextStyle get header1ThemeColor => themeProvider.header1ThemeColor;
  TextStyle get header2 => themeProvider.header2;
  TextStyle get header2ThemeColor => themeProvider.header2ThemeColor;
  TextStyle get header3 => themeProvider.header3;

  BoxDecoration get classicDecoration => themeProvider.classicDecoration;
  BoxDecoration get classicDecorationWhite =>
      themeProvider.classicDecorationWhite;
  BoxDecoration get classicDecorationDark =>
      themeProvider.classicDecorationDark;
  BoxDecoration get classicDecorationSharp =>
      themeProvider.classicDecorationSharp;
  BoxDecoration get classicDecorationSharper =>
      themeProvider.classicDecorationSharper;
  BoxDecoration get classicDecorationWhiteSharper =>
      themeProvider.classicDecorationWhiteSharper;
  BoxDecoration get classicDecorationWhiteSharperHover =>
      themeProvider.classicDecorationWhiteSharperHover;
  BoxDecoration get classicDecorationWhiteSharperActive =>
      themeProvider.classicDecorationWhiteSharperActive;
  BoxDecoration get classicDecorationDarkSharper =>
      themeProvider.classicDecorationDarkSharper;
  BoxDecoration get darkDecorationSharper =>
      themeProvider.darkDecorationSharper;
  BoxDecoration get mediumDarkDecorationSharper =>
      themeProvider.mediumDarkDecorationSharper;
  BoxDecoration get darkDecoration => themeProvider.darkDecoration;

  Border get bottomBorder => themeProvider.bottomBorder;
  Border get bottomBorderDark => themeProvider.bottomBorderDark;
  List<BoxShadow> get cardShadow => themeProvider.cardShadow;
}
