class LessonProgressEntity {
  final String courseId;
  final String lessonId;
  final int watchedSeconds;
  final double progressPercentage;
  final bool completed;
  final DateTime? completedAt;
  final DateTime? lastSyncedAt;

  LessonProgressEntity({
    required this.courseId,
    required this.lessonId,
    required this.watchedSeconds,
    required this.progressPercentage,
    required this.completed,
    this.completedAt,
    this.lastSyncedAt,
  });

  LessonProgressEntity copyWith({
    String? courseId,
    String? lessonId,
    int? watchedSeconds,
    double? progressPercentage,
    bool? completed,
    DateTime? completedAt,
    DateTime? lastSyncedAt,
  }) {
    return LessonProgressEntity(
      courseId: courseId ?? this.courseId,
      lessonId: lessonId ?? this.lessonId,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
