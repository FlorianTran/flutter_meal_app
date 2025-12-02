import 'package:flutter/material.dart';

/// Application theme configuration
/// Based on Figma design with green primary color
class AppTheme {
  // Green color scheme from Figma
  static const Color primaryGreen = Color(0xFF6CBF4A);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color backgroundLight = Colors.white;
  
  // Standard text color (not pure black, easier on eyes)
  static const Color textBlack = Color(0xFF212121);

  /// Get the appropriate font family based on font weight
  /// Uses SansationLight for light weights (w300 and below), Sansation for others
  static String getFontFamily(FontWeight? weight) {
    if (weight == null) return 'Sansation';
    if (weight.value <= FontWeight.w300.value) {
      return 'SansationLight';
    }
    return 'Sansation';
  }

  /// Create a TextStyle with the appropriate font family based on weight
  static TextStyle textStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(fontWeight),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textBlack,
      height: height,
      decoration: decoration,
    );
  }

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: lightGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundLight,
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Sansation',
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: const TextStyle(fontFamily: 'Sansation', fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 32, fontWeight: FontWeight.w400),
      headlineMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 28, fontWeight: FontWeight.w400),
      headlineSmall: const TextStyle(fontFamily: 'Sansation', fontSize: 24, fontWeight: FontWeight.w400),
      titleLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: const TextStyle(fontFamily: 'Sansation', fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: const TextStyle(fontFamily: 'SansationLight', fontSize: 12, fontWeight: FontWeight.w300),
      labelLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: const TextStyle(fontFamily: 'SansationLight', fontSize: 11, fontWeight: FontWeight.w300),
    ).apply(
      bodyColor: textBlack,
      displayColor: textBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textBlack,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: lightGreen,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Sansation',
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: const TextStyle(fontFamily: 'Sansation', fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 32, fontWeight: FontWeight.w400),
      headlineMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 28, fontWeight: FontWeight.w400),
      headlineSmall: const TextStyle(fontFamily: 'Sansation', fontSize: 24, fontWeight: FontWeight.w400),
      titleLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: const TextStyle(fontFamily: 'Sansation', fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: const TextStyle(fontFamily: 'SansationLight', fontSize: 12, fontWeight: FontWeight.w300),
      labelLarge: const TextStyle(fontFamily: 'Sansation', fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: const TextStyle(fontFamily: 'Sansation', fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: const TextStyle(fontFamily: 'SansationLight', fontSize: 11, fontWeight: FontWeight.w300),
    ),
  );
}
