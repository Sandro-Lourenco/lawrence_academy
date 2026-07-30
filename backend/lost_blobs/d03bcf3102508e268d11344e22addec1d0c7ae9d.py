import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical app and feature trees do not import legacy trees', () {
    final roots = [Directory('lib/app'), Directory('lib/features')];
    final legacyImport = RegExp(
      r'''package:lawrence/(presentation|ui|data)/''',
    );
    final violations = <String>[];

    for (final root in roots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          if (legacyImport.hasMatch(lines[index])) {
            violations.add('${entity.path}:${index + 1}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Canonical code must not import presentation, ui, or data roots.',
    );
  });

  test('migrated learning presentation does not import data', () {
    final roots = [
      Directory('lib/features/courses/presentation'),
      Directory('lib/features/lessons/presentation'),
      Directory('lib/features/lesson_progress/presentation'),
      Directory('lib/features/dashboard/presentation'),
      Directory('lib/features/player/presentation'),
    ];
    final dataImport = RegExp(r'''import\s+['"][^'"]*data/''');
    final violations = <String>[];

    for (final root in roots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          if (dataImport.hasMatch(lines[index])) {
            violations.add('${entity.path}:${index + 1}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Migrated presentation layers must use domain or app providers.',
    );
  });
}
