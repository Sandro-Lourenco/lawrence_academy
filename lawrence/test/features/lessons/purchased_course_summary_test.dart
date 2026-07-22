import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/lesson_progress/domain/entities/lesson_progress_entity.dart';
import 'package:lawrence/features/lessons/presentation/controllers/purchased_course_presentation.dart';

void main() {
  final course = Course(
    id: 'course-1',
    instructorId: 'teacher-1',
    title: 'Costura',
    slug: 'costura',
    category: 'costura',
    level: 'iniciante',
    summary: '',
    status: 'published',
    modules: [
      Module(
        id: 'module-1',
        courseId: 'course-1',
        title: 'Introdução',
        orderIndex: 0,
        lessons: [
          _lesson('lesson-1', 0),
          _lesson('lesson-2', 1),
          _lesson('lesson-3', 2),
        ],
      ),
    ],
  );

  test('summarizes completed and partial lesson progress', () {
    final summary = summarizePurchasedCourse(course, [
      _progress('lesson-1', 100, completed: true),
      _progress('lesson-2', 50),
    ]);

    expect(summary.totalLessons, 3);
    expect(summary.completedLessons, 1);
    expect(summary.progress, closeTo(0.5, 0.001));
    expect(summary.nextLesson?.id, 'lesson-2');
  });

  test('clamps invalid progress values', () {
    final summary = summarizePurchasedCourse(course, [
      _progress('lesson-1', 180),
      _progress('lesson-2', -20),
    ]);

    expect(summary.progress, closeTo(1 / 3, 0.001));
  });

  test('ignores progress belonging to another course', () {
    final foreign = LessonProgressEntity(
      courseId: 'another-course',
      lessonId: 'lesson-1',
      watchedSeconds: 600,
      progressPercentage: 100,
      completed: true,
    );

    final summary = summarizePurchasedCourse(course, [foreign]);

    expect(summary.completedLessons, 0);
    expect(summary.progress, 0);
    expect(summary.nextLesson?.id, 'lesson-1');
  });
}

Lesson _lesson(String id, int order) => Lesson(
  id: id,
  moduleId: 'module-1',
  courseId: 'course-1',
  title: 'Aula $order',
  status: 'published',
  orderIndex: order,
  durationSeconds: 600,
  aiSummary: const AISummary(
    title: '',
    executiveSummary: '',
    keyTakeaways: [],
    stepByStepExecution: [],
    technicalGlossary: [],
  ),
);

LessonProgressEntity _progress(
  String lessonId,
  double percentage, {
  bool completed = false,
}) => LessonProgressEntity(
  courseId: 'course-1',
  lessonId: lessonId,
  watchedSeconds: 0,
  progressPercentage: percentage,
  completed: completed,
);
