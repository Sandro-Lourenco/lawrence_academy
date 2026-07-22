import '../../domain/entities/lesson_progress_entity.dart';
import '../../domain/repositories/lesson_progress_repository_interface.dart';

class UpdateLessonProgressUseCase {
  final ILessonProgressRepository _repository;

  UpdateLessonProgressUseCase(this._repository);

  Future<void> execute({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required double progressPercentage,
    required bool completed,
  }) async {
    final progress = LessonProgressEntity(
      courseId: courseId,
      lessonId: lessonId,
      watchedSeconds: watchedSeconds,
      progressPercentage: progressPercentage,
      completed: completed,
      completedAt: completed ? DateTime.now() : null,
    );
    await _repository.saveProgressLocally(progress);
  }
}
