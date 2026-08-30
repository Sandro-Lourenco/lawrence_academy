import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/public/public_editorial_colors.dart';

double contrastRatio(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('canonical editorial text pairs meet WCAG AA', () {
    final pairs = <(Color, Color)>[
      (PublicEditorialColors.ink, PublicEditorialColors.ivory),
      (PublicEditorialColors.ivory, PublicEditorialColors.ink),
      (PublicEditorialColors.white, PublicEditorialColors.wine),
      (PublicEditorialColors.ivory, PublicEditorialColors.plum),
      (PublicEditorialColors.champagne, PublicEditorialColors.plum),
      (PublicEditorialColors.wine, PublicEditorialColors.ivory),
    ];

    for (final pair in pairs) {
      expect(
        contrastRatio(pair.$1, pair.$2),
        greaterThanOrEqualTo(4.5),
        reason: 'Foreground ${pair.$1} on ${pair.$2} must meet WCAG AA',
      );
    }
  });
}
