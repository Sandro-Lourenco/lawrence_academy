import 'package:flutter/material.dart';

abstract final class PublicMotion {
  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 420);
  static const entranceCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;
  static const hoverScale = 1.01;
  static const pressedScale = 0.97;
  static const revealDistance = 14.0;

  static Duration accessibleDuration(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

class PublicReveal extends StatelessWidget {
  const PublicReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (disabled) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: PublicMotion.slow + delay,
      curve: PublicMotion.entranceCurve,
      child: child,
      builder: (context, value, child) {
        final delayedValue = delay == Duration.zero
            ? value
            : ((value - 0.18) / 0.82).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, (1 - delayedValue) * PublicMotion.revealDistance),
            child: child,
          ),
        );
      },
    );
  }
}
