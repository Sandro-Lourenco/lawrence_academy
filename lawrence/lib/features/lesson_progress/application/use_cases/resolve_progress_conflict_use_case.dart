import '../../domain/entities/lesson_progress_entity.dart';

class ResolveProgressConflictUseCase {
  LessonProgressEntity execute({
    required LessonProgressEntity local,
    required LessonProgressEntity remote,
  }) {
    // 1. completed = true sempre prevalece
    final isCompleted = local.completed || remote.completed;

    // 2. Maior watched_seconds válido prevalece (não regredir)
    final maxSeconds = local.watchedSeconds > remote.watchedSeconds
        ? local.watchedSeconds
        : remote.watchedSeconds;

    // 3. progress_percentage é o maior valor (ou recalculado, mas garantimos que não regrida)
    final maxPercentage = local.progressPercentage > remote.progressPercentage
        ? local.progressPercentage
        : remote.progressPercentage;

    // 4. completed_at é determinado
    final resolvedCompletedAt = isCompleted
        ? (local.completedAt ?? remote.completedAt ?? DateTime.now())
        : null;

    // 5. O lastSyncedAt é o do remote ou timestamp do servidor
    final resolvedSyncedAt = remote.lastSyncedAt ?? DateTime.now();

    return LessonProgressEntity(
      courseId: local.courseId,
      lessonId: local.lessonId,
      watchedSeconds: maxSeconds,
      progressPercentage: maxPercentage,
      completed: isCompleted,
      completedAt: resolvedCompletedAt,
      lastSyncedAt: resolvedSyncedAt,
    );
  }
}
