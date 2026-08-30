import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoldenEditorialButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const GoldenEditorialButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<GoldenEditorialButton> createState() => _GoldenEditorialButtonState();
}

class _GoldenEditorialButtonState extends State<GoldenEditorialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero, // Editorial sharp corners
            gradient: LinearGradient(
              colors: _isHovered
                  ? [
                      const Color(0xFFD4AF37), // Lighter Gold
                      const Color(0xFFFFF2CD),
                      const Color(0xFFC59B27),
                    ]
                  : [
                      const Color(0xFFBF953F), // Base Gold
                      const Color(0xFFFCF6BA),
                      const Color(0xFFB38728),
                      const Color(0xFFFBF5B7),
                      const Color(0xFFAA771C),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFBF953F).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 5.0,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
