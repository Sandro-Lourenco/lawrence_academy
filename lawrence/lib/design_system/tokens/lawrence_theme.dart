import 'package:flutter/material.dart';

class LawrenceColors {
  // Cores do Design System (Proporção 60-30-10)
  // 60% Base
  static const Color canvas = Color(0xFFFFFFFF); // Pure White
  static const Color canvasParchment = Color(0xFFF8F9FB); // Parchment White

  // 30% Action/Graphite
  static const Color primary = Color(
    0xFF0A84FF,
  ); // Deep Learning Blue (CTA, links, progresso)
  static const Color primaryFocus = Color(0xFF0071E3); // Focus Ring
  static const Color primaryOnDark = Color(0xFF2997FF); // Sky Link Blue
  static const Color textPrimary = Color(0xFF1D1D1F); // Deep Graphite
  static const Color surfaceTile2 = Color(0xFF272729); // Dark Tile Secondary
  static const Color surfaceBlack = Color(0xFF000000); // Absolute Black

  // Borders & Dividers
  static const Color borderMist = Color(0xFFE8E8ED); // Silver Mist
  static const Color textSecondary = Color(0xFF8E8E93); // Soft Gray
  static const Color textMuted = Color(0xFFCCCCCC); // Text Muted

  // 10% Premium/Semantics
  static const Color accentGold = Color(
    0xFFD4AF37,
  ); // Premium Gold (Certificados/Badges)
  static const Color success = Color(0xFF30D158); // Success Green
  static const Color warning = Color(0xFFFF9F0A); // Warning Orange
  static const Color danger = Color(0xFFFF453A); // Danger Red
  static const Color info = Color(0xFF64D2FF); // Info Light Blue
}

class LawrenceTheme {
  static const double gridUnit = 4.0;
  static double grid(int multiplier) => gridUnit * multiplier;

  // Bordas Arredondadas (Rounded Corners)
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: LawrenceColors.primary,
        secondary: LawrenceColors.textPrimary,
        surface: LawrenceColors.canvas,
        error: LawrenceColors.danger,
        onPrimary: LawrenceColors.canvas,
        onSecondary: LawrenceColors.canvas,
        onSurface: LawrenceColors.textPrimary,
      ),
      scaffoldBackgroundColor: LawrenceColors.canvasParchment,
      fontFamily: 'Inter',
      dividerTheme: const DividerThemeData(
        color: LawrenceColors.borderMist,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        // Hero XL (64px, bold, tracking negativo -0.4px)
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 64.0,
          fontWeight: FontWeight.bold,
          height: 1.1,
          letterSpacing: -0.4,
          color: LawrenceColors.textPrimary,
        ),
        // Display L (48px, semibold, tracking negativo -0.32px)
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 48.0,
          fontWeight: FontWeight.w600,
          height: 1.1,
          letterSpacing: -0.32,
          color: LawrenceColors.textPrimary,
        ),
        // Display M (36px, semibold, tracking negativo -0.28px)
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.28,
          color: LawrenceColors.textPrimary,
        ),
        // Heading L (28px, semibold, tracking negativo -0.2px)
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.2,
          color: LawrenceColors.textPrimary,
        ),
        // Heading M (22px, semibold, tracking negativo -0.16px)
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.16,
          color: LawrenceColors.textPrimary,
        ),
        // Body L Strong (17px, semibold, tracking negativo -0.374px)
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.374,
          color: LawrenceColors.textPrimary,
        ),
        // Body L (17px, regular, tracking -0.374px)
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17.0,
          fontWeight: FontWeight.normal,
          height: 1.3,
          letterSpacing: -0.374,
          color: LawrenceColors.textPrimary,
        ),
        // Body M (15px, regular, tracking -0.24px)
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
          height: 1.35,
          letterSpacing: -0.24,
          color: LawrenceColors.textSecondary,
        ),
        // Caption (12px, regular, tracking 0.0px)
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          height: 1.4,
          letterSpacing: 0.0,
          color: LawrenceColors.textSecondary,
        ),
      ),
    );
  }
}
