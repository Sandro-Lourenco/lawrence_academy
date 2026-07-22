import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lessons/domain/entities/lesson_entity.dart';
import 'package:lawrence/features/player/presentation/controllers/lesson_navigation_presentation.dart';

void main() {
  final lessons = [
    _lesson('lesson-1', 'course-1', 'published'),
    _lesson('draft', 'course-1', 'draft'),
    _lesson('lesson-2', 'course-1', 'published'),
    _lesson('foreign', 'course-2', 'published'),
    _lesson('lesson-3', 'course-1', 'preview'),
  ];

  test('resolves previous and next among available lessons of the course', () {
    final navigation = resolveLessonNavigation(
      lessons,
      courseId: 'course-1',
      lessonId: 'lesson-2',
    );

    expect(navigation.previous?.id, 'lesson-1');
    expect(navigation.next?.id, 'lesson-3');
  });

  test('does not reveal navigation for an unknown lesson', () {
    final navigation = resolveLessonNavigation(
      lessons,
      courseId: 'course-1',
      lessonId: 'foreign',
    );

    expect(navigation.previous, isNull);
    expect(navigation.next, isNull);
  });
}

LessonEntity _lesson(String id, String courseId, String status) => LessonEntity(
  id: id,
  moduleId: 'module-1',
  courseId: courseId,
  title: id,
  orderIndex: 0,
  durationSeconds: 600,
  hlsStoragePath: '',
  status: status,
);
