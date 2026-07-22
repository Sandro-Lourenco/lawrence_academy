// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

class LawrenceColors {
  // Base e superfícies.
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasParchment = Color(0xFFF7F9FC);
  static const Color surfaceSubtle = Color(0xFFF0F4F9);

  // Marca e ações. actionPrimary possui contraste AA com texto branco.
  static const Color brandNavy = Color(0xFF08265B);
  static const Color actionPrimary = Color(0xFF0067D9);
  static const Color actionPrimaryHover = Color(0xFF0058BC);
  static const Color actionPrimaryPressed = Color(0xFF004A9F);
  static const Color focusRing = Color(0xFF005FCC);
  static const Color actionOnDark = Color(0xFF5BB0FF);

  // Conteúdo.
  static const Color textPrimary = Color(0xFF10264F);
  static const Color textSecondary = Color(0xFF52627C);
  static const Color textDisabled = Color(0xFF7C879A);
  static const Color surfaceTile2 = Color(0xFF272729);
  static const Color surfaceBlack = Color(0xFF000000); // Absolute Black

  // Bordas e divisores.
  static const Color borderMist = Color(0xFFD9E0EA);

  // Contexto de prática e projetos. Não representa erro.
  static const Color practice = Color(0xFFC92C73);
  static const Color practiceSurface = Color(0xFFFDEAF3);

  // Estados semânticos, sempre acompanhados por ícone e texto.
  static const Color success = Color(0xFF168447);
  static const Color successSurface = Color(0xFFE9F7EF);
  static const Color warning = Color(0xFF9A5B00);
  static const Color warningSurface = Color(0xFFFFF4DA);
  static const Color danger = Color(0xFFBA1A1A);
  static const Color dangerSurface = Color(0xFFFFEDEA);
  static const Color info = Color(0xFF075E9E);
  static const Color infoSurface = Color(0xFFEAF4FC);
  static const Color achievement = Color(0xFF8A5A00);

  // Aliases legados. Novos componentes devem usar os tokens semânticos acima.
  static const Color primary = actionPrimary;
  static const Color primaryFocus = focusRing;
  static const Color primaryOnDark = actionOnDark;
  static const Color textMuted = textDisabled;
  static const Color accentGold = achievement;
}

class LawrenceBreakpoints {
  static const double mobileCompact = 320;
  static const double mobileWide = 390;
  static const double tablet = 700;
  static const double desktop = 1100;

  static bool isMobile(double width) => width < tablet;
  static bool isTablet(double width) => width >= tablet && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}

class LawrenceSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class LawrenceRadii {
  static const double control = 8;
  static const double card = 16;
  static const double featured = 24;
  static const double pill = 999;
}

class LawrenceTheme {
  static const double gridUnit = 4.0;
  static double grid(int multiplier) => gridUnit * multiplier;

  // Bordas Arredondadas (Rounded Corners)
  static const double radiusXs = LawrenceRadii.control;
  static const double radiusSm = LawrenceRadii.control;
  static const double radiusMd = LawrenceRadii.card;
  static const double radiusLg = LawrenceRadii.featured;
  static const double radiusXl = LawrenceRadii.pill;

  // Backwards compatibility for UI that uses LawrenceTheme.primary etc.
  static const Color primary = LawrenceColors.primary;
  static const Color textPrimary = LawrenceColors.textPrimary;
  static const Color textSecondary = LawrenceColors.textSecondary;
  static const Color surfaceTile1 = LawrenceColors
      .surfaceTile2; // Alias since surfaceTile1 might have been renamed to surfaceTile2
  static const Color warning = LawrenceColors.warning;
  static const Color danger = LawrenceColors.danger;
  static const Color info = LawrenceColors.info;
  static const Color success = LawrenceColors.success;
  static const Color canvas = LawrenceColors.canvas;
  static const Color surfaceBlack = LawrenceColors.surfaceBlack;
  static const Color accentGold = LawrenceColors.accentGold;
  static const Color borderMist = LawrenceColors.borderMist;
  static const Color textMuted = LawrenceColors.textMuted;
  static const Color primaryFocus = LawrenceColors.primaryFocus;
  static const Color canvasParchment = LawrenceColors.canvasParchment;
  static const Color accent = LawrenceColors.accentGold;

  // Scales de Liquid Glass
  static const double AppGlassBlurSubtle = 8.0;
  static const double AppGlassBlurMedium = 20.0;
  static const double AppGlassBlurStrong = 40.0;

  static const double AppGlassOpacitySubtle = 0.30;
  static const double AppGlassOpacityMedium = 0.72;
  static const double AppGlassOpacityStrong = 0.90;

  static const double AppMotionScalePressed = 0.97;
  static const double AppMotionScaleHover = 1.02;

  static const double AppRadiusSmall = 8.0;
  static const double AppRadiusMedium = 16.0;
  static const double AppRadiusLarge = 24.0;

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
      cardTheme: CardThemeData(
        color: LawrenceColors.canvas,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.card),
          side: const BorderSide(color: LawrenceColors.borderMist),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: LawrenceColors.actionPrimary,
          foregroundColor: LawrenceColors.canvas,
          disabledBackgroundColor: LawrenceColors.surfaceSubtle,
          disabledForegroundColor: LawrenceColors.textDisabled,
          padding: const EdgeInsets.symmetric(
            horizontal: LawrenceSpacing.lg,
            vertical: LawrenceSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: LawrenceColors.actionPrimary,
          side: const BorderSide(color: LawrenceColors.actionPrimary),
          padding: const EdgeInsets.symmetric(
            horizontal: LawrenceSpacing.lg,
            vertical: LawrenceSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LawrenceColors.canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LawrenceSpacing.md,
          vertical: LawrenceSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
          borderSide: const BorderSide(color: LawrenceColors.borderMist),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
          borderSide: const BorderSide(color: LawrenceColors.borderMist),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
          borderSide: const BorderSide(
            color: LawrenceColors.focusRing,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
          borderSide: const BorderSide(color: LawrenceColors.danger),
        ),
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
