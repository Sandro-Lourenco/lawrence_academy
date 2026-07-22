import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lesson_progress/data/mappers/lesson_progress_mapper.dart';
import 'package:lawrence/features/lesson_progress/domain/entities/lesson_progress_entity.dart';

void main() {
  test('lesson progress API mapper uses canonical persistence fields', () {
    final payload = LessonProgressMapper.toApi(
      LessonProgressEntity(
        courseId: 'course-1',
        lessonId: 'lesson-1',
        watchedSeconds: 120,
        progressPercentage: 42.5,
        completed: false,
      ),
    );

    expect(
      payload.keys,
      containsAll(<String>{
        'course_id',
        'lesson_id',
        'watched_seconds',
        'progress_percentage',
        'completed',
        'completed_at',
      }),
    );
    expect(payload, isNot(contains('progress')));
    expect(payload, isNot(contains('last_position_seconds')));
  });

  test('canonical Flutter tree does not reference legacy progress route', () {
    final violations = <String>[];
    for (final entity in Directory('lib/features').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.readAsStringSync().contains('/students/me/progress')) {
        violations.add(entity.path);
      }
    }

    expect(violations, isEmpty);
  });
}
