import 'package:flutter/material.dart';
import 'package:filmu_nams/providers/theme_provider.dart';

class Style extends InheritedWidget {
  final ThemeProvider themeProvider;

  const Style({
    super.key,
    required this.themeProvider,
    required super.child,
  });

  @override
  bool updateShouldNotify(Style oldWidget) {
    return themeProvider != oldWidget.themeProvider;
  }

  static Style of(BuildContext context) {
    final Style? result = context.dependOnInheritedWidgetOfExactType<Style>();
    assert(result != null, 'No ColorContext found in context');
    return result!;
  }

  bool get isDark => themeProvider.isDark;

  Color get primary => themeProvider.currentTheme.colorScheme.primary;
  Color get onPrimary => themeProvider.currentTheme.colorScheme.onPrimary;
  Color get primaryContainer =>
      themeProvider.currentTheme.colorScheme.primaryContainer;
  Color get onPrimaryContainer =>
      themeProvider.currentTheme.colorScheme.onPrimaryContainer;
  Color get secondary => themeProvider.currentTheme.colorScheme.secondary;
  Color get onSecondary => themeProvider.currentTheme.colorScheme.onSecondary;
  Color get secondaryContainer =>
      themeProvider.currentTheme.colorScheme.secondaryContainer;
  Color get onSecondaryContainer =>
      themeProvider.currentTheme.colorScheme.onSecondaryContainer;
  Color get tertiary => themeProvider.currentTheme.colorScheme.tertiary;
  Color get onTertiary => themeProvider.currentTheme.colorScheme.onTertiary;
  Color get tertiaryContainer =>
      themeProvider.currentTheme.colorScheme.tertiaryContainer;
  Color get onTertiaryContainer =>
      themeProvider.currentTheme.colorScheme.onTertiaryContainer;
  Color get error => themeProvider.currentTheme.colorScheme.error;
  Color get onError => themeProvider.currentTheme.colorScheme.onError;
  Color get errorContainer =>
      themeProvider.currentTheme.colorScheme.errorContainer;
  Color get onErrorContainer =>
      themeProvider.currentTheme.colorScheme.onErrorContainer;
  Color get background => themeProvider.currentTheme.colorScheme.background;
  Color get onBackground => themeProvider.currentTheme.colorScheme.onBackground;
  Color get surface => themeProvider.currentTheme.colorScheme.surface;
  Color get onSurface => themeProvider.currentTheme.colorScheme.onSurface;
  Color get surfaceVariant =>
      themeProvider.currentTheme.colorScheme.surfaceVariant;
  Color get onSurfaceVariant =>
      themeProvider.currentTheme.colorScheme.onSurfaceVariant;
  Color get outline => themeProvider.currentTheme.colorScheme.outline;
  Color get shadow => themeProvider.currentTheme.colorScheme.shadow;
  Color get inverseSurface =>
      themeProvider.currentTheme.colorScheme.inverseSurface;
  Color get onInverseSurface =>
      themeProvider.currentTheme.colorScheme.onInverseSurface;
  Color get inversePrimary =>
      themeProvider.currentTheme.colorScheme.inversePrimary;
  Color get surfaceTint => themeProvider.currentTheme.colorScheme.surfaceTint;

  TextStyle get displayLarge =>
      themeProvider.currentTheme.textTheme.displayLarge!;
  TextStyle get displayMedium =>
      themeProvider.currentTheme.textTheme.displayMedium!;
  TextStyle get displaySmall =>
      themeProvider.currentTheme.textTheme.displaySmall!;
  TextStyle get headlineLarge =>
      themeProvider.currentTheme.textTheme.headlineLarge!;
  TextStyle get headlineMedium =>
      themeProvider.currentTheme.textTheme.headlineMedium!;
  TextStyle get headlineSmall =>
      themeProvider.currentTheme.textTheme.headlineSmall!;
  TextStyle get titleLarge => themeProvider.currentTheme.textTheme.titleLarge!;
  TextStyle get titleMedium =>
      themeProvider.currentTheme.textTheme.titleMedium!;
  TextStyle get titleSmall => themeProvider.currentTheme.textTheme.titleSmall!;
  TextStyle get labelLarge => themeProvider.currentTheme.textTheme.labelLarge!;
  TextStyle get labelMedium =>
      themeProvider.currentTheme.textTheme.labelMedium!;
  TextStyle get labelSmall => themeProvider.currentTheme.textTheme.labelSmall!;
  TextStyle get bodyLarge => themeProvider.currentTheme.textTheme.bodyLarge!;
  TextStyle get bodyMedium => themeProvider.currentTheme.textTheme.bodyMedium!;
  TextStyle get bodySmall => themeProvider.currentTheme.textTheme.bodySmall!;

  Color get contrast => isDark ? Colors.white : Colors.black;
  Color get themeBgColor => isDark ? Colors.black : Colors.white;

  BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.05 : 1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: contrast.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: isDark
            ? [BoxShadow()]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
      );

  BoxDecoration get roundCardDecoration => BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.05 : 1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark
            ? [BoxShadow()]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
      );

  BoxDecoration get accentCardDecoration => BoxDecoration(
        color: primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: secondary.withOpacity(0.1),
          width: 1,
        ),
      );

  BoxDecoration get opaqueCardDecoration => BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: contrast.withOpacity(0.1),
          width: 1,
        ),
      );

  BoxDecoration get activeCardDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      );

  BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadow.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      );

  BoxDecoration get gradientCardDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  BoxDecoration get ticketDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: labelLarge.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: primary,
        ),
      );
}
