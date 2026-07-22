import '../../domain/repositories/lesson_progress_repository_interface.dart';

class SyncLessonProgressUseCase {
  final ILessonProgressRepository _repository;

  SyncLessonProgressUseCase(this._repository);

  Future<void> execute() {
    return _repository.processSyncQueue();
  }
}
