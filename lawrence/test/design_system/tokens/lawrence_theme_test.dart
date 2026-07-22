import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/tokens/lawrence_theme.dart';

void main() {
  group('LawrenceBreakpoints', () {
    test('classifica os limites sem sobreposição', () {
      expect(LawrenceBreakpoints.isMobile(699), isTrue);
      expect(LawrenceBreakpoints.isTablet(700), isTrue);
      expect(LawrenceBreakpoints.isTablet(1099), isTrue);
      expect(LawrenceBreakpoints.isDesktop(1100), isTrue);
    });
  });

  group('contraste da paleta do aluno', () {
    test('texto branco em ação primária atende WCAG AA', () {
      expect(
        _contrastRatio(LawrenceColors.actionPrimary, Colors.white),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('cores semânticas usadas como texto atendem WCAG AA no branco', () {
      const semanticTextColors = [
        LawrenceColors.practice,
        LawrenceColors.success,
        LawrenceColors.warning,
        LawrenceColors.danger,
        LawrenceColors.info,
        LawrenceColors.achievement,
        LawrenceColors.textPrimary,
        LawrenceColors.textSecondary,
      ];

      for (final color in semanticTextColors) {
        expect(
          _contrastRatio(color, Colors.white),
          greaterThanOrEqualTo(4.5),
          reason: '${color.toARGB32().toRadixString(16)} falhou no contraste',
        );
      }
    });
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}
