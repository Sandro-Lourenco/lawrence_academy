import 'package:flutter/material.dart';

class TailorGridPainter extends CustomPainter {
  final bool dark;

  TailorGridPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dark ? Colors.white.withOpacity(0.015) : Colors.black.withOpacity(0.01)
      ..strokeWidth = 1.0;

    // Draw vertical dotted grid lines
    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += 4.0) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }

    // Draw horizontal dotted grid lines
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += 4.0) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }

    // Draw tailor cross marks at grid intersections
    final accentPaint = Paint()
      ..color = dark ? Colors.white.withOpacity(0.035) : Colors.black.withOpacity(0.02)
      ..strokeWidth = 1.0;

    for (double x = spacing; x < size.width; x += spacing * 3) {
      for (double y = spacing; y < size.height; y += spacing * 3) {
        canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), accentPaint);
        canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), accentPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
