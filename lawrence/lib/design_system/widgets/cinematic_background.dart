import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

class CinematicBackground extends StatefulWidget {
  final Widget child;

  const CinematicBackground({super.key, required this.child});

  @override
  State<CinematicBackground> createState() => _CinematicBackgroundState();
}

class _CinematicBackgroundState extends State<CinematicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _motionEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled =
        !MediaQuery.disableAnimationsOf(context) && TickerMode.of(context);
    if (enabled == _motionEnabled) return;
    _motionEnabled = enabled;
    if (enabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = .5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? LawrenceColors.brandNavy
        : LawrenceColors.canvas;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: background),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _AtelierLightPainter(
                progress: _controller.value,
                dark: isDark,
                accent: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),

        // Foreground content
        widget.child,
      ],
    );
  }
}

class _AtelierLightPainter extends CustomPainter {
  final double progress;
  final bool dark;
  final Color accent;

  const _AtelierLightPainter({
    required this.progress,
    required this.dark,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drift = (progress - .5) * size.width * .035;
    final light = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accent.withValues(alpha: dark ? .09 : .13),
              accent.withValues(alpha: dark ? .025 : .045),
              Colors.transparent,
            ],
            stops: const [0, .38, 1],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .72 + drift, size.height * .20),
              radius: size.longestSide * .62,
            ),
          );
    canvas.drawRect(Offset.zero & size, light);

    final pattern = Paint()
      ..color = (dark ? Colors.white : LawrenceColors.brandNavy).withValues(
        alpha: dark ? .035 : .028,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..moveTo(size.width * .08, size.height)
      ..quadraticBezierTo(
        size.width * .34,
        size.height * .50,
        size.width * .18,
        0,
      )
      ..moveTo(size.width * .88, 0)
      ..quadraticBezierTo(
        size.width * .68,
        size.height * .48,
        size.width * .93,
        size.height,
      );
    canvas.drawPath(path, pattern);
  }

  @override
  bool shouldRepaint(covariant _AtelierLightPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.dark != dark;
}
