import '../../../lessons/domain/entities/lesson_entity.dart';

class LessonNavigation {
  final LessonEntity? previous;
  final LessonEntity? next;

  const LessonNavigation({this.previous, this.next});
}

LessonNavigation resolveLessonNavigation(
  Iterable<LessonEntity> lessons, {
  required String courseId,
  required String lessonId,
}) {
  final available = lessons
      .where(
        (lesson) =>
            lesson.courseId == courseId &&
            (lesson.status == 'published' || lesson.status == 'preview'),
      )
      .toList(growable: false);
  final index = available.indexWhere((lesson) => lesson.id == lessonId);
  if (index < 0) return const LessonNavigation();
  return LessonNavigation(
    previous: index > 0 ? available[index - 1] : null,
    next: index + 1 < available.length ? available[index + 1] : null,
  );
}
