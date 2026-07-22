import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/lawrence_theme.dart';

class LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.borderRadius = LawrenceTheme.AppRadiusLarge,
    this.width,
    this.height,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  State<LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<LiquidGlassCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _scale = LawrenceTheme.AppMotionScalePressed;
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg =
        widget.backgroundColor ??
        Colors.white.withValues(alpha: LawrenceTheme.AppGlassOpacityMedium);
    final themeBorder =
        widget.borderColor ?? Colors.white.withValues(alpha: 0.28);

    final cardContent = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: themeBg,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: themeBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: LawrenceTheme.AppGlassBlurMedium,
            sigmaY: LawrenceTheme.AppGlassBlurMedium,
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    Widget mainWidget = widget.margin != null
        ? Padding(padding: widget.margin!, child: cardContent)
        : cardContent;

    if (widget.onTap == null) {
      return mainWidget;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scale, _scale, 1.0),
        transformAlignment: Alignment.center,
        child: mainWidget,
      ),
    );
  }
}
