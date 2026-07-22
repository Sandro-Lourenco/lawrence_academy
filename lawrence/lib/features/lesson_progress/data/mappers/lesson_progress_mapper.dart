import '../../domain/entities/lesson_progress_entity.dart';

class LessonProgressMapper {
  static LessonProgressEntity fromSQLite(Map<String, dynamic> map) {
    return LessonProgressEntity(
      courseId: map['course_id'] as String,
      lessonId: map['lesson_id'] as String,
      watchedSeconds: map['watched_seconds'] as int,
      progressPercentage: (map['progress_percentage'] as num).toDouble(),
      completed: (map['completed'] as int) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.tryParse(map['last_synced_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toSQLite(LessonProgressEntity entity) {
    return {
      'course_id': entity.courseId,
      'lesson_id': entity.lessonId,
      'watched_seconds': entity.watchedSeconds,
      'progress_percentage': entity.progressPercentage,
      'completed': entity.completed ? 1 : 0,
      'completed_at': entity.completedAt?.toIso8601String(),
      'last_synced_at': entity.lastSyncedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> toApi(LessonProgressEntity entity) {
    return {
      'course_id': entity.courseId,
      'lesson_id': entity.lessonId,
      'watched_seconds': entity.watchedSeconds,
      'progress_percentage': entity.progressPercentage,
      'completed': entity.completed,
      'completed_at': entity.completedAt?.toIso8601String(),
    };
  }
}
