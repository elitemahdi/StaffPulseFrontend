import 'package:flutter/material.dart';

class AppTheme {
  // Apple System & Glass Accent Colors
  static const Color appleBlue = Color(0xFF0A84FF);
  static const Color appleIndigo = Color(0xFF5E5CE6);
  static const Color applePurple = Color(0xFFBF5AF2);
  static const Color appleTeal = Color(0xFF64D2FF);
  static const Color appleGreen = Color(0xFF30D158);
  static const Color appleOrange = Color(0xFFFF9F0A);
  static const Color appleRed = Color(0xFFFF453A);

  // Backgrounds for Liquid Glass Effect (Dark Obsidian / Space)
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF161B26);
  static const Color darkGlassBackground = Color(0xFF10141D);

  // Glass Specular Borders & Highlights
  static const Color glassBorderColor = Color(0x33FFFFFF);
  static const Color glassHighlightColor = Color(0x55FFFFFF);
  static const Color glassSurfaceColor = Color(0x1AFFFFFF);

  /// Apple-Style Liquid Glass Dark Theme
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: appleBlue,
      secondary: appleIndigo,
      tertiary: appleTeal,
      surface: darkSurface,
      error: appleRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFF2F2F7),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: 'Vazirmatn', // Clean Persian font or system fallback
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: glassSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: glassBorderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1FFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: appleBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: appleRed, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
        ),
        prefixIconColor: Colors.white.withValues(alpha: 0.7),
        suffixIconColor: Colors.white.withValues(alpha: 0.7),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appleBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
        bodyLarge: TextStyle(color: Color(0xFFE5E5EA), fontSize: 15),
        bodyMedium: TextStyle(color: Color(0xFFD1D1D6), fontSize: 13),
        bodySmall: TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
      ),
    );
  }
}
