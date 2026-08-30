import 'dart:ui';

import 'package:flutter/material.dart';

import 'public_editorial_colors.dart';

/// A restrained optical-glass surface for the public navigation.
///
/// The ivory veil keeps dark navigation text readable over photography. A
/// faint static tonal shift suggests refraction without a glossy top stripe or
/// continuous motion.
class PublicRefractiveGlass extends StatelessWidget {
  const PublicRefractiveGlass({
    super.key,
    required this.child,
    this.borderRadius = 0,
    this.blurSigma = 18,
    this.elevated = false,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(borderRadius);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: PublicEditorialColors.ink.withValues(alpha: 0.14),
              blurRadius: elevated ? 22 : 15,
              spreadRadius: -8,
              offset: Offset(0, elevated ? 10 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: reduceMotion ? 0 : blurSigma,
              sigmaY: reduceMotion ? 0 : blurSigma,
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [0, 0.34, 0.68, 1],
                        colors: [
                          PublicEditorialColors.ivory.withValues(
                            alpha: elevated ? 0.76 : 0.62,
                          ),
                          PublicEditorialColors.parchment.withValues(
                            alpha: elevated ? 0.7 : 0.56,
                          ),
                          PublicEditorialColors.ivory.withValues(
                            alpha: elevated ? 0.72 : 0.58,
                          ),
                          PublicEditorialColors.white.withValues(
                            alpha: elevated ? 0.68 : 0.54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.7, -1),
                          end: const Alignment(0.35, 1),
                          colors: [
                            Colors.transparent,
                            PublicEditorialColors.wine.withValues(alpha: 0.025),
                            PublicEditorialColors.champagne.withValues(
                              alpha: 0.07,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 1,
                  child: ColoredBox(
                    color: PublicEditorialColors.white.withValues(alpha: .46),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 1,
                  child: ColoredBox(
                    color: PublicEditorialColors.wine.withValues(alpha: 0.42),
                  ),
                ),
                Positioned(
                  left: 48,
                  right: 48,
                  bottom: 3,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          PublicEditorialColors.antiqueGold.withValues(
                            alpha: 0.36,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
