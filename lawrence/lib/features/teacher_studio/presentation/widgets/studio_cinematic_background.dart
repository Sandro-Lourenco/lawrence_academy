import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';

ThemeData studioTheme(BuildContext context) {
  final base = Theme.of(context);
  const gold = LawrenceColors.goldHighlight;
  const ink = LawrenceColors.surfaceBlack;
  const surface = LawrenceColors.surfaceTile2;
  const secondary = Color(0xFFE2D4CA);
  final outline = Colors.white.withValues(alpha: .22);
  const radius = BorderRadius.zero;

  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: gold,
      onPrimary: ink,
      surface: surface,
      onSurface: Colors.white,
      outline: outline,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.white.withValues(alpha: .14),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xB22C111B),
      labelStyle: const TextStyle(color: secondary),
      floatingLabelStyle: const TextStyle(color: gold),
      hintStyle: const TextStyle(color: Color(0xFF929DB8)),
      helperStyle: const TextStyle(color: Color(0xFFABB5CD)),
      counterStyle: const TextStyle(color: Color(0xFFABB5CD)),
      errorStyle: const TextStyle(color: Color(0xFFFFA8B0)),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: gold, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: LawrenceColors.danger),
      ),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(color: Colors.white),
      menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(surface)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFE88A)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: .34)),
        minimumSize: const Size(48, 48),
      ),
    ),
  );
}

/// Ambient backdrop for the authoring studio. The expensive blur is isolated
/// in a repaint boundary and never repeated inside course lists.
class StudioCinematicBackground extends StatelessWidget {
  const StudioCinematicBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0B10), Color(0xFF2C111B), Color(0xFF16090E)],
          ),
        ),
      ),
      const Positioned(
        top: -180,
        right: -100,
        width: 620,
        height: 520,
        child: _AmbientOrb(colors: [Color(0x44B38A4A), Color(0x00B38A4A)]),
      ),
      const Positioned(
        bottom: -240,
        left: -100,
        width: 700,
        height: 620,
        child: _AmbientOrb(colors: [Color(0x446B1328), Color(0x006B1328)]),
      ),
      const Positioned(
        top: 220,
        left: 360,
        width: 520,
        height: 420,
        child: _AmbientOrb(colors: [Color(0x33CFA9A8), Color(0x00CFA9A8)]),
      ),
      child,
    ],
  );
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 54, sigmaY: 54),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    ),
  );
}

class StudioGlassPanel extends StatelessWidget {
  const StudioGlassPanel({
    required this.child,
    this.padding,
    this.radius = 0,
    this.strong = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool strong;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: strong ? 22 : 14,
          sigmaY: strong ? 22 : 14,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: strong ? .12 : .075),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
              BoxShadow(
                color: Color(0x22B38A4A),
                blurRadius: 34,
                spreadRadius: -10,
              ),
            ],
          ),
          child: child,
        ),
      ),
    ),
  );
}

class StudioModalBackdrop extends StatelessWidget {
  const StudioModalBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
    child: child,
    builder: (context, value, child) => RepaintBoundary(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18 * value, sigmaY: 18 * value),
        child: ColoredBox(
          color: const Color(0xFF1A0B10).withValues(alpha: .62 * value),
          child: Transform.scale(
            scale: .96 + (.04 * value),
            child: Opacity(opacity: value, child: child),
          ),
        ),
      ),
    ),
  );
}

class StudioModalPanel extends StatelessWidget {
  const StudioModalPanel({
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.width,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;

  @override
  Widget build(BuildContext context) => Theme(
    data: studioTheme(context),
    child: StudioGlassPanel(
      strong: true,
      radius: 0,
      padding: padding,
      child: SizedBox(width: width, child: child),
    ),
  );
}
