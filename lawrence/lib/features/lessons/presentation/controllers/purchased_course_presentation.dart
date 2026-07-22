import '../../../courses/domain/entities/course.dart';
import '../../../lesson_progress/domain/entities/lesson_progress_entity.dart';

class PurchasedCourseSummary {
  final int totalLessons;
  final int completedLessons;
  final double progress;
  final Lesson? nextLesson;

  const PurchasedCourseSummary({
    required this.totalLessons,
    required this.completedLessons,
    required this.progress,
    required this.nextLesson,
  });
}

PurchasedCourseSummary summarizePurchasedCourse(
  Course course,
  Iterable<LessonProgressEntity> progressItems,
) {
  final lessons = [for (final module in course.modules) ...module.lessons];
  final progressByLesson = {
    for (final item in progressItems)
      if (item.courseId == course.id) item.lessonId: item,
  };
  if (lessons.isEmpty) {
    return const PurchasedCourseSummary(
      totalLessons: 0,
      completedLessons: 0,
      progress: 0,
      nextLesson: null,
    );
  }

  var completed = 0;
  var totalProgress = 0.0;
  Lesson? partialLesson;
  Lesson? firstIncomplete;
  for (final lesson in lessons) {
    final item = progressByLesson[lesson.id];
    final isCompleted = item?.completed ?? false;
    final percentage = isCompleted
        ? 100.0
        : (item?.progressPercentage ?? 0).clamp(0.0, 100.0).toDouble();
    totalProgress += percentage;
    if (isCompleted) {
      completed++;
    } else {
      firstIncomplete ??= lesson;
      if (percentage > 0) partialLesson ??= lesson;
    }
  }

  return PurchasedCourseSummary(
    totalLessons: lessons.length,
    completedLessons: completed,
    progress: (totalProgress / lessons.length / 100)
        .clamp(0.0, 1.0)
        .toDouble(),
    nextLesson: partialLesson ?? firstIncomplete,
  );
}
