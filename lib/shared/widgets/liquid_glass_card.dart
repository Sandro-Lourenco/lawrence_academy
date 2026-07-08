import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? width;
  final double? height;
  final Color? borderColor;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.borderRadius = 24.0, // Regra inegociável: circular(24)
    this.width,
    this.height,
    this.borderColor,
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
        _scale = 0.97; // Regra inegociável: escala 0.97 no clique
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
    // Regra inegociável: padrão estrito para o efeito de vidro profissional (Liquid Glass)
    final cardContent = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor ?? Colors.white.withOpacity(0.28)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    Widget mainWidget = widget.margin != null
        ? Padding(padding: widget.margin!, child: cardContent)
        : cardContent;

    if (widget.onTap == null) {
      return mainWidget;
    }

    // Regra inegociável: InkWell/GestureDetector com feedback de escala de 0.97
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scale),
        transformAlignment: Alignment.center,
        child: mainWidget,
      ),
    );
  }
}
