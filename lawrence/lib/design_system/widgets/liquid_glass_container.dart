import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

/// A bounded glass surface with a deterministic opaque fallback.
///
/// Keep this widget around isolated navigation, dialog or feature surfaces.
/// Applying it to repeated list items or a full page creates expensive web
/// backdrop passes and can make CanvasKit startup noticeably slower.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool enableBlur;
  final bool showHighlight;
  final Color fallbackColor;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = LawrenceTheme.AppRadiusMedium,
    this.blurSigma = LawrenceTheme.AppGlassBlurMedium,
    this.backgroundColor = const Color(0xB8FFFFFF), // 72% opacity white
    this.borderColor = const Color(0x1FE8E8ED),
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.enableBlur = true,
    this.showHighlight = true,
    this.fallbackColor = const Color(0xF2FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final reduceEffects = MediaQuery.disableAnimationsOf(context);
    final blurEnabled = enableBlur && !reduceEffects && blurSigma > 0;

    final surface = Stack(
      fit: StackFit.passthrough,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: blurEnabled ? backgroundColor : fallbackColor,
            borderRadius: radius,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
        if (showHighlight)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, 0.28, 0.62, 1],
                    colors: [
                      Color(0x47FFFFFF),
                      Color(0x10FFFFFF),
                      Color(0x08000000),
                      Color(0x22FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final filteredSurface = blurEnabled
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            blendMode: BlendMode.srcOver,
            child: surface,
          )
        : surface;

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: filteredSurface,
        ),
      ),
    );
  }
}
