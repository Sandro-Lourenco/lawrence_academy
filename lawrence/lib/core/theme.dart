import 'package:flutter/material.dart';

class LawrenceTheme {
  // Cores do Design System (Proporção 60-30-10)
  static const Color primary = Color(
    0xFF0A84FF,
  ); // Deep Learning Blue (10% Interatividade/Ação)
  static const Color primaryFocus = Color(0xFF0071E3); // Focus Ring
  static const Color primaryOnDark = Color(0xFF2997FF); // Sky Link Blue
  static const Color accent = Color(
    0xFFD4AF37,
  ); // Premium Gold (Badges/Certificados/Destaque)

  static const Color canvas = Color(
    0xFFFFFFFF,
  ); // Pure White (60% Base principal)
  static const Color canvasParchment = Color(
    0xFFF8F9FB,
  ); // Parchment White (Base secundária)

  static const Color surfacePearl = Color(0xFFFAFAFC); // Pearl Button
  static const Color surfaceTile1 = Color(
    0xFF1D1D1F,
  ); // Deep Graphite (Texto principal/Elementos 30%)
  static const Color surfaceTile2 = Color(0xFF272729); // Dark Tile Secondary
  static const Color surfaceBlack = Color(0xFF000000); // Absolute Black

  static const Color borderMist = Color(0xFFE8E8ED); // Silver Mist
  static const Color textSecondary = Color(0xFF8E8E93); // Soft Gray
  static const Color textMuted = Color(0xFFCCCCCC); // Text Muted on Dark

  // Cores Semânticas
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color danger = Color(0xFFFF453A);
  static const Color info = Color(0xFF64D2FF);

  // Espaçamentos Baseados no Grid de 4px
  static const double gridUnit = 4.0;
  static double grid(int multiplier) => gridUnit * multiplier;

  // Bordas Arredondadas (Rounded Corners)
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  // Estilos de Texto Editorial (SF Pro / Inter)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: surfaceTile1,
        surface: canvas,
        error: danger,
      ),
      scaffoldBackgroundColor: canvasParchment,
      textTheme: const TextTheme(
        // Hero XL (64px, bold, tracking negativo -0.4px)
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 64.0,
          fontWeight: FontWeight.bold,
          height: 1.1,
          letterSpacing: -0.4,
          color: surfaceTile1,
        ),
        // Display L (48px, semibold, tracking negativo -0.32px)
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 48.0,
          fontWeight: FontWeight.w600,
          height: 1.1,
          letterSpacing: -0.32,
          color: surfaceTile1,
        ),
        // Display M (36px, semibold, tracking negativo -0.28px)
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.28,
          color: surfaceTile1,
        ),
        // Heading L (28px, semibold, tracking negativo -0.2px)
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.2,
          color: surfaceTile1,
        ),
        // Heading M (22px, semibold, tracking negativo -0.16px)
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.16,
          color: surfaceTile1,
        ),
        // Body L Strong (17px, semibold, tracking negativo -0.374px)
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
          height: 1.24,
          letterSpacing: -0.374,
          color: surfaceTile1,
        ),
        // Body L (17px, regular, tracking negativo -0.374px)
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17.0,
          fontWeight: FontWeight.normal,
          height: 1.47,
          letterSpacing: -0.374,
          color: surfaceTile1,
        ),
        // Body M (15px, regular, tracking negativo -0.2px)
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
          height: 1.4,
          letterSpacing: -0.2,
          color: surfaceTile1,
        ),
        // Caption (13px, regular, tracking negativo -0.1px)
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.0,
          fontWeight: FontWeight.normal,
          height: 1.4,
          letterSpacing: -0.1,
          color: textSecondary,
        ),
        // Micro (11px, regular)
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.0,
          fontWeight: FontWeight.normal,
          height: 1.3,
          letterSpacing: 0.0,
          color: textSecondary,
        ),
      ),
    );
  }
}
