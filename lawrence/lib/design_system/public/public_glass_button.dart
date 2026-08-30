import 'package:flutter/material.dart';

import '../motion/public_motion.dart';
import 'public_editorial_colors.dart';
import 'public_editorial_typography.dart';

enum PublicGlassButtonTone { wine, ivory, quiet }

/// The single public CTA language used across the Maison Lawrence experience.
///
/// The refractive impression is painted with translucent layers instead of a
/// BackdropFilter per button. This keeps course grids inexpensive to rasterize.
class PublicGlassButton extends StatefulWidget {
  const PublicGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = PublicGlassButtonTone.wine,
    this.icon = Icons.arrow_forward_rounded,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final PublicGlassButtonTone tone;
  final IconData? icon;
  final bool expand;
  final String? semanticLabel;

  @override
  State<PublicGlassButton> createState() => _PublicGlassButtonState();
}

class _PublicGlassButtonState extends State<PublicGlassButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final colors = _palette(widget.tone, disabled);
    final duration = reduceMotion ? Duration.zero : PublicMotion.fast;

    return Semantics(
      container: true,
      explicitChildNodes: false,
      button: true,
      enabled: !disabled,
      label: widget.semanticLabel ?? widget.label,
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: disabled
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          onEnter: disabled ? null : (_) => setState(() => _hovered = true),
          onExit: disabled ? null : (_) => setState(() => _hovered = false),
          child: AnimatedScale(
            scale: reduceMotion
                ? 1
                : _pressed
                ? PublicMotion.pressedScale
                : _hovered
                ? PublicMotion.hoverScale
                : 1,
            duration: duration,
            curve: PublicMotion.entranceCurve,
            child: AnimatedContainer(
              duration: duration,
              constraints: BoxConstraints(
                minWidth: widget.expand ? double.infinity : 0,
                minHeight: 50,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _hovered && !disabled
                      ? colors.hoverGradient
                      : colors.gradient,
                  stops: const [0, .42, 1],
                ),
                border: Border.all(color: colors.border),
                boxShadow: disabled
                    ? const []
                    : [
                        BoxShadow(
                          color: colors.shadow,
                          blurRadius: _hovered ? 18 : 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PublicEditorialColors.white.withValues(alpha: .18),
                    Colors.transparent,
                    PublicEditorialColors.ink.withValues(alpha: .05),
                  ],
                  stops: const [0, .28, 1],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  onHighlightChanged: disabled
                      ? null
                      : (value) => setState(() => _pressed = value),
                  focusColor: colors.foreground.withValues(alpha: .12),
                  hoverColor: Colors.transparent,
                  splashColor: colors.foreground.withValues(alpha: .10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: widget.expand
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PublicEditorialTypography.buttonLabel(
                              color: colors.foreground,
                            ),
                          ),
                        ),
                        if (widget.icon != null) ...[
                          const SizedBox(width: 12),
                          AnimatedSlide(
                            duration: duration,
                            curve: PublicMotion.entranceCurve,
                            offset: _hovered && !disabled
                                ? const Offset(.16, 0)
                                : Offset.zero,
                            child: Icon(
                              widget.icon,
                              size: 18,
                              color: colors.foreground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_GlassPalette _palette(PublicGlassButtonTone tone, bool disabled) {
  if (disabled) {
    return _GlassPalette(
      gradient: const [Color(0x99706468), Color(0x99706468), Color(0x99706468)],
      hoverGradient: const [
        Color(0x99706468),
        Color(0x99706468),
        Color(0x99706468),
      ],
      foreground: PublicEditorialColors.ivory,
      border: PublicEditorialColors.mutedInk.withValues(alpha: .36),
      shadow: Colors.transparent,
    );
  }
  return switch (tone) {
    PublicGlassButtonTone.ivory => _GlassPalette(
      gradient: const [Color(0xFFFDF9F4), Color(0xE6F7F0E8), Color(0xD9E9DECF)],
      hoverGradient: const [
        Color(0xFFFFFFFF),
        Color(0xFFF7F0E8),
        Color(0xFFE8D2B0),
      ],
      foreground: PublicEditorialColors.wine,
      border: PublicEditorialColors.white.withValues(alpha: .78),
      shadow: PublicEditorialColors.ink.withValues(alpha: .14),
    ),
    PublicGlassButtonTone.quiet => _GlassPalette(
      gradient: const [Color(0x26FFFFFF), Color(0x12FFFFFF), Color(0x0DFFFFFF)],
      hoverGradient: const [
        Color(0x40FFFFFF),
        Color(0x20FFFFFF),
        Color(0x12FFFFFF),
      ],
      foreground: PublicEditorialColors.ivory,
      border: PublicEditorialColors.ivory.withValues(alpha: .48),
      shadow: PublicEditorialColors.noir.withValues(alpha: .16),
    ),
    PublicGlassButtonTone.wine => _GlassPalette(
      gradient: const [Color(0xF2811D3B), Color(0xF26B1328), Color(0xF22C111B)],
      hoverGradient: const [
        Color(0xFF98284A),
        Color(0xFF811D3B),
        Color(0xFF4A101E),
      ],
      foreground: PublicEditorialColors.ivory,
      border: PublicEditorialColors.champagne.withValues(alpha: .54),
      shadow: PublicEditorialColors.wine.withValues(alpha: .28),
    ),
  };
}

class _GlassPalette {
  const _GlassPalette({
    required this.gradient,
    required this.hoverGradient,
    required this.foreground,
    required this.border,
    required this.shadow,
  });

  final List<Color> gradient;
  final List<Color> hoverGradient;
  final Color foreground;
  final Color border;
  final Color shadow;
}
