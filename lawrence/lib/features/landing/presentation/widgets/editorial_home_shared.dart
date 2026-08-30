import 'package:flutter/material.dart';

import '../../../../design_system/motion/public_motion.dart';
import '../../../../design_system/public/public_editorial_colors.dart';
import '../../../../design_system/public/public_editorial_typography.dart';
import '../../../../design_system/public/public_glass_button.dart';

const publicMobileBreakpoint = 700.0;
const publicDesktopBreakpoint = 1100.0;

class EditorialSection extends StatelessWidget {
  const EditorialSection({
    super.key,
    required this.child,
    this.background = PublicEditorialColors.ivory,
    this.padding,
    this.maxWidth = 1440,
  });

  final Widget child;
  final Color background;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < publicMobileBreakpoint
        ? 24.0
        : width < publicDesktopBreakpoint
        ? 48.0
        : 72.0;
    final vertical = width < publicMobileBreakpoint ? 80.0 : 132.0;
    return ColoredBox(
      color: background,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: vertical,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class MaisonButton extends StatelessWidget {
  const MaisonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.light = false,
    this.trailingIcon = Icons.arrow_forward,
    this.expand = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool light;
  final IconData trailingIcon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return PublicGlassButton(
      label: label,
      onPressed: onPressed,
      icon: trailingIcon,
      expand: expand,
      tone: light ? PublicGlassButtonTone.ivory : PublicGlassButtonTone.wine,
    );
  }
}

class EditorialTextLink extends StatelessWidget {
  const EditorialTextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.onDark = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark
        ? PublicEditorialColors.ivory
        : PublicEditorialColors.wine;
    return TextButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        textStyle: PublicEditorialTypography.buttonLabel(color: color),
        shape: const RoundedRectangleBorder(),
      ),
    );
  }
}

class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow(this.text, {super.key, this.onDark = false});

  final String text;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark
        ? PublicEditorialColors.champagne
        : PublicEditorialColors.wine;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 36, height: 1, color: color),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: PublicEditorialTypography.eyebrow(color: color),
          ),
        ),
      ],
    );
  }
}

class HoverZoomImage extends StatefulWidget {
  const HoverZoomImage({
    super.key,
    required this.asset,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String asset;
  final String semanticLabel;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<HoverZoomImage> createState() => _HoverZoomImageState();
}

class _HoverZoomImageState extends State<HoverZoomImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ClipRect(
        child: RepaintBoundary(
          child: AnimatedScale(
            scale: !reduceMotion && _hovered ? PublicMotion.hoverScale : 1,
            duration: PublicMotion.accessibleDuration(
              context,
              PublicMotion.fast,
            ),
            curve: PublicMotion.entranceCurve,
            child: Image.asset(
              widget.asset,
              semanticLabel: widget.semanticLabel,
              fit: widget.fit,
              alignment: widget.alignment,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

class EditorialOrnament extends StatelessWidget {
  const EditorialOrnament({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark
        ? PublicEditorialColors.champagne
        : PublicEditorialColors.wine;
    return ExcludeSemantics(
      child: SizedBox(
        width: 88,
        height: 88,
        child: CustomPaint(painter: _PatternOrnamentPainter(color)),
      ),
    );
  }
}

class _PatternOrnamentPainter extends CustomPainter {
  const _PatternOrnamentPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    canvas.drawOval(rect, paint);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.62,
        height: size.height * 0.62,
      ),
      -0.8,
      3.8,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PatternOrnamentPainter oldDelegate) =>
      oldDelegate.color != color;
}
