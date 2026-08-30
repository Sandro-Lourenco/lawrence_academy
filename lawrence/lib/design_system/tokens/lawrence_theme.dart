// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LawrenceColors {
  // Base e superfícies.
  static const Color canvas = Color(0xFFF7F0E8);
  static const Color canvasParchment = Color(0xFFEDE1D2);
  static const Color surfaceSubtle = Color(0xFFF1E7DC);

  // Marca e ações. actionPrimary possui contraste AA com texto branco.
  static const Color wine = Color(0xFF6B1328);
  static const Color ruby = Color(0xFF811D3B);
  static const Color plum = Color(0xFF2C111B);
  static const Color brandNavy = wine; // Alias legado; a marca não é azul.
  static const Color actionPrimary = wine;
  static const Color actionPrimaryHover = ruby;
  static const Color actionPrimaryPressed = Color(0xFF4B0C1B);
  static const Color focusRing = Color(0xFFA63B5E);
  static const Color actionOnDark = Color(0xFFF7F0E8);

  // Conteúdo.
  static const Color textPrimary = Color(0xFF181315);
  static const Color textSecondary = Color(0xFF62565A);
  static const Color textDisabled = Color(0xFF7A6D71);
  static const Color surfaceTile2 = plum;
  static const Color surfaceBlack = Color(0xFF181315);

  // Superfícies autenticadas no modo escuro: neutras, nunca vinho.
  static const Color darkCanvas = Color(0xFF0C0C0E);
  static const Color darkSurface = Color(0xFF151518);
  static const Color darkElevated = Color(0xFF1D1D21);
  static const Color darkBorder = Color(0xFF34343A);
  static const Color darkTextPrimary = Color(0xFFF6F3EF);
  static const Color darkTextSecondary = Color(0xFFBEB8B4);
  static const Color darkAction = wine;
  static const Color darkActionHover = Color(0xFFB94A6B);
  static const Color darkActionPressed = Color(0xFF811D3B);

  // Bordas e divisores.
  static const Color borderMist = Color(0xFFD8C8BA);
  static const Color border = borderMist;

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
  static const Color achievement = Color(0xFF7A4F00);
  static const Color goldHighlight = Color(0xFFE8D2B0);
  static const Color goldBright = Color(0xFFD4B47E);
  static const Color goldMid = Color(0xFFB38A4A);
  static const Color goldDeep = Color(0xFF8C642B);
  static const Color goldShadow = Color(0xFF68471F);
  static const Color onGold = brandNavy;
  static const Color goldSoft = goldDeep;
  static const Color goldDisabled = Color(0xFFE4E0D6);
  static const Color onGoldDisabled = Color(0xFF737373);
  static const List<Color> goldFoilGradient = <Color>[
    goldHighlight,
    goldBright,
    goldMid,
    goldDeep,
    goldShadow,
  ];
  static const List<double> goldFoilStops = <double>[0, .25, .5, .75, 1];

  // Quartier Latin Red
  static const Color qlRed = brandNavy;
  static const Color qlRedHover = actionPrimaryHover;
  static const Color qlRedPressed = actionPrimaryPressed;

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
  static const double control = 2;
  static const double card = 0;
  static const double featured = 0;
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
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.surfaceBlack,
        fontSize: 64.0,
        fontWeight: FontWeight.w400,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.surfaceBlack,
        fontSize: 48.0,
        fontWeight: FontWeight.w400,
        height: 1.1,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.surfaceBlack,
        fontSize: 36.0,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.surfaceBlack,
        fontSize: 28.0,
        fontWeight: FontWeight.w400,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.surfaceBlack,
        fontSize: 22.0,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.inter(
        color: LawrenceColors.surfaceBlack,
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: LawrenceColors.surfaceBlack,
        fontSize: 17.0,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: LawrenceColors.textSecondary,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        color: LawrenceColors.textSecondary,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: LawrenceColors.brandNavy,
        secondary: LawrenceColors.actionPrimaryHover,
        surface: LawrenceColors.canvas,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: Color(0xFFFCF9F5),
        surfaceContainer: LawrenceColors.surfaceSubtle,
        surfaceContainerHigh: LawrenceColors.canvasParchment,
        surfaceContainerHighest: Color(0xFFE6D9CD),
        error: LawrenceColors.danger,
        onPrimary: LawrenceColors.canvas,
        onSecondary: LawrenceColors.canvas,
        onSurface: LawrenceColors.surfaceBlack,
        onSurfaceVariant: LawrenceColors.textSecondary,
        outline: LawrenceColors.borderMist,
        outlineVariant: Color(0xFFE7DDD4),
      ),
      scaffoldBackgroundColor: LawrenceColors.canvas,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: LawrenceColors.borderMist,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: LawrenceColors.canvas,
        foregroundColor: LawrenceColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: LawrenceColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
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
          backgroundColor: LawrenceColors.brandNavy,
          foregroundColor: LawrenceColors.canvas,
          disabledBackgroundColor: LawrenceColors.goldDisabled,
          disabledForegroundColor: LawrenceColors.onGoldDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: LawrenceColors.brandNavy,
          foregroundColor: LawrenceColors.canvas,
          disabledBackgroundColor: LawrenceColors.goldDisabled,
          disabledForegroundColor: LawrenceColors.onGoldDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: LawrenceColors.brandNavy,
          side: const BorderSide(color: LawrenceColors.brandNavy),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: LawrenceColors.brandNavy,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: LawrenceColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
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
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: const WidgetStatePropertyAll(
          BorderSide(color: LawrenceColors.borderMist),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
        ),
        hintStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(color: LawrenceColors.textSecondary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: LawrenceColors.brandNavy,
        disabledColor: LawrenceColors.surfaceSubtle,
        labelStyle: GoogleFonts.inter(color: LawrenceColors.textPrimary),
        secondaryLabelStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: LawrenceColors.borderMist),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: LawrenceColors.canvas,
        surfaceTintColor: Colors.transparent,
        indicatorColor: LawrenceColors.brandNavy.withValues(alpha: .12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            color: states.contains(WidgetState.selected)
                ? LawrenceColors.brandNavy
                : LawrenceColors.textSecondary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: LawrenceColors.canvas,
        indicatorColor: LawrenceColors.brandNavy.withValues(alpha: .12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
        ),
        selectedIconTheme: const IconThemeData(color: LawrenceColors.brandNavy),
        unselectedIconTheme: const IconThemeData(
          color: LawrenceColors.textSecondary,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.card),
          side: const BorderSide(color: LawrenceColors.borderMist),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: LawrenceColors.surfaceBlack,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        actionTextColor: LawrenceColors.goldHighlight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: LawrenceColors.borderMist),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: LawrenceColors.surfaceBlack,
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
        ),
        textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LawrenceColors.brandNavy,
        linearTrackColor: LawrenceColors.borderMist,
        circularTrackColor: LawrenceColors.borderMist,
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.darkTextPrimary,
        fontSize: 64.0,
        fontWeight: FontWeight.w400,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.darkTextPrimary,
        fontSize: 48.0,
        fontWeight: FontWeight.w400,
        height: 1.1,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.darkTextPrimary,
        fontSize: 36.0,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.darkTextPrimary,
        fontSize: 28.0,
        fontWeight: FontWeight.w400,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        color: LawrenceColors.darkTextPrimary,
        fontSize: 22.0,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.inter(
        color: LawrenceColors.darkTextPrimary,
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: LawrenceColors.darkTextPrimary,
        fontSize: 17.0,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: LawrenceColors.darkTextSecondary,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.inter(
        color: LawrenceColors.darkTextSecondary,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: LawrenceColors.darkAction,
        secondary: LawrenceColors.brandNavy,
        surface: LawrenceColors.darkSurface,
        surfaceContainerLowest: LawrenceColors.darkCanvas,
        surfaceContainerLow: LawrenceColors.darkSurface,
        surfaceContainer: LawrenceColors.darkElevated,
        surfaceContainerHigh: Color(0xFF242429),
        surfaceContainerHighest: LawrenceColors.darkElevated,
        error: LawrenceColors.danger,
        onPrimary: LawrenceColors.darkTextPrimary,
        onSecondary: LawrenceColors.darkTextPrimary,
        onSurface: LawrenceColors.darkTextPrimary,
        onSurfaceVariant: LawrenceColors.darkTextSecondary,
        outline: LawrenceColors.darkBorder,
        outlineVariant: LawrenceColors.darkBorder,
      ),
      scaffoldBackgroundColor: LawrenceColors.darkCanvas,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: LawrenceColors.darkBorder,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: LawrenceColors.darkCanvas,
        foregroundColor: LawrenceColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: LawrenceColors.darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: LawrenceColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: LawrenceColors.darkBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: LawrenceColors.darkAction,
          foregroundColor: LawrenceColors.darkTextPrimary,
          disabledBackgroundColor: LawrenceColors.darkElevated,
          disabledForegroundColor: LawrenceColors.darkTextSecondary,
          elevation: 0,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: LawrenceColors.darkAction,
          foregroundColor: LawrenceColors.darkTextPrimary,
          disabledBackgroundColor: LawrenceColors.darkElevated,
          disabledForegroundColor: LawrenceColors.darkTextSecondary,
          elevation: 0,
          shadowColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: .3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: LawrenceColors.darkTextPrimary,
          side: const BorderSide(color: LawrenceColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            letterSpacing: .3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: LawrenceColors.darkTextPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: LawrenceColors.darkTextPrimary,
          shape: const RoundedRectangleBorder(),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: LawrenceColors.darkSurface,
        labelStyle: TextStyle(color: LawrenceColors.darkTextSecondary),
        hintStyle: TextStyle(color: LawrenceColors.darkTextSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: LawrenceColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: LawrenceColors.focusRing, width: 2),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(
          LawrenceColors.darkSurface,
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        side: const WidgetStatePropertyAll(
          BorderSide(color: LawrenceColors.darkBorder),
        ),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        hintStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(color: LawrenceColors.darkTextSecondary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LawrenceColors.darkSurface,
        selectedColor: LawrenceColors.darkAction,
        disabledColor: LawrenceColors.darkElevated,
        labelStyle: GoogleFonts.inter(color: LawrenceColors.darkTextPrimary),
        secondaryLabelStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: LawrenceColors.darkBorder),
        shape: const RoundedRectangleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: LawrenceColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: LawrenceColors.darkAction.withValues(alpha: .22),
        indicatorShape: const RoundedRectangleBorder(),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: LawrenceColors.darkSurface,
        indicatorColor: LawrenceColors.darkAction.withValues(alpha: .22),
        indicatorShape: const RoundedRectangleBorder(),
        selectedIconTheme: const IconThemeData(
          color: LawrenceColors.darkTextPrimary,
        ),
        unselectedIconTheme: const IconThemeData(
          color: LawrenceColors.darkTextSecondary,
        ),
      ),
      dialogTheme: const DialogThemeData(
        elevation: 0,
        backgroundColor: LawrenceColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: LawrenceColors.darkBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: LawrenceColors.darkElevated,
        contentTextStyle: GoogleFonts.inter(
          color: LawrenceColors.darkTextPrimary,
        ),
        actionTextColor: LawrenceColors.darkTextPrimary,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: LawrenceColors.darkBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: LawrenceColors.darkSurface,
        modalBackgroundColor: LawrenceColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: LawrenceColors.darkBorder),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LawrenceColors.darkAction,
        linearTrackColor: LawrenceColors.darkBorder,
        circularTrackColor: LawrenceColors.darkBorder,
      ),
    );
  }
}
