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

  test('migrated feature layers do not depend on data', () {
    final roots = [
      Directory('lib/features/courses/presentation'),
      Directory('lib/features/lessons/presentation'),
      Directory('lib/features/lesson_progress/presentation'),
      Directory('lib/features/dashboard/presentation'),
      Directory('lib/features/player/presentation'),
      Directory('lib/features/auth/presentation'),
      Directory('lib/features/certificates/presentation'),
      Directory('lib/features/invoices/presentation'),
      Directory('lib/features/teacher_studio/presentation'),
      Directory('lib/features/teacher_studio/domain'),
      Directory('lib/features/sync/application'),
      Directory('lib/features/sync/domain'),
      Directory('lib/features/subscriptions/presentation'),
      Directory('lib/features/subscriptions/application'),
      Directory('lib/features/subscriptions/domain'),
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

  test('canonical feature facades do not compose data adapters', () {
    final facades = [
      File('lib/features/subscriptions/subscriptions_providers.dart'),
    ];
    final dataImport = RegExp(r'''(?:import|export)\s+['"][^'"]*data/''');
    final violations = <String>[];

    for (final facade in facades) {
      final lines = facade.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (dataImport.hasMatch(lines[index])) {
          violations.add('${facade.path}:${index + 1}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Feature facades must delegate composition to app/providers.',
    );
  });

  test('migrated presentation does not call the network layer directly', () {
    final roots = [
      Directory('lib/features/dashboard/presentation'),
      Directory('lib/features/profile/presentation'),
    ];
    final networkImport = RegExp(r'''core/network/''');
    final violations = <String>[];

    for (final root in roots) {
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final lines = entity.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          if (networkImport.hasMatch(lines[index])) {
            violations.add('${entity.path}:${index + 1}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Presentation must reach HTTP through use cases and repositories.',
    );
  });

  test('migrated teacher and checkout calls use canonical v1 paths', () {
    final teacherSource = File(
      'lib/features/teacher_studio/data/datasources/'
      'teacher_course_remote_data_source.dart',
    ).readAsStringSync();
    final subscriptionSource = File(
      'lib/features/subscriptions/data/datasources/'
      'subscription_remote_datasource.dart',
    ).readAsStringSync();

    expect(teacherSource.contains("'/teacher/courses"), isFalse);
    expect(subscriptionSource.contains("'/payments/checkout',"), isFalse);
  });
}
