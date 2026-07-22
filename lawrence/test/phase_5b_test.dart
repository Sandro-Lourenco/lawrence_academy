import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lesson_progress/application/use_cases/resolve_progress_conflict_use_case.dart';
import 'package:lawrence/features/lesson_progress/domain/entities/lesson_progress_entity.dart';
import 'package:lawrence/features/lessons/domain/entities/lesson_entity.dart';

void main() {
  group("Phase 5B - Progress Conflict Resolution Tests", () {
    final conflictUseCase = ResolveProgressConflictUseCase();

    test("completed=true wins over completed=false", () {
      final local = LessonProgressEntity(
        courseId: "course-1",
        lessonId: "lesson-1",
        watchedSeconds: 100,
        progressPercentage: 50.0,
        completed: false,
      );

      final remote = LessonProgressEntity(
        courseId: "course-1",
        lessonId: "lesson-1",
        watchedSeconds: 180,
        progressPercentage: 90.0,
        completed: true,
      );

      final resolved = conflictUseCase.execute(local: local, remote: remote);
      expect(resolved.completed, true);
      expect(resolved.watchedSeconds, 180);
      expect(resolved.progressPercentage, 90.0);
    });

    test("max watched_seconds wins (no regression)", () {
      final local = LessonProgressEntity(
        courseId: "course-1",
        lessonId: "lesson-1",
        watchedSeconds: 150,
        progressPercentage: 75.0,
        completed: false,
      );

      final remote = LessonProgressEntity(
        courseId: "course-1",
        lessonId: "lesson-1",
        watchedSeconds: 100,
        progressPercentage: 50.0,
        completed: false,
      );

      final resolved = conflictUseCase.execute(local: local, remote: remote);
      expect(resolved.completed, false);
      expect(resolved.watchedSeconds, 150);
      expect(resolved.progressPercentage, 75.0);
    });
  });

  group("Phase 5B - Lesson Entity Access Tests", () {
    test("lesson status preview maps to isPreview true", () {
      final lesson = LessonEntity(
        id: "lesson-1",
        moduleId: "module-1",
        courseId: "course-1",
        title: "Introduction",
        orderIndex: 1,
        durationSeconds: 300,
        hlsStoragePath: "path/to/stream.m3u8",
        status: "preview",
      );

      expect(lesson.isPreview, true);
    });

    test("lesson status published maps to isPreview false", () {
      final lesson = LessonEntity(
        id: "lesson-2",
        moduleId: "module-1",
        courseId: "course-1",
        title: "Deep Dive",
        orderIndex: 2,
        durationSeconds: 600,
        hlsStoragePath: "path/to/stream2.m3u8",
        status: "published",
      );

      expect(lesson.isPreview, false);
    });
  });
}
