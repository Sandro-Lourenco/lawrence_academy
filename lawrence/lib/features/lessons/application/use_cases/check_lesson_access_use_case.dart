import '../../domain/repositories/lesson_repository_interface.dart';

class CheckLessonAccessUseCase {
  final ILessonRepository _repository;

  CheckLessonAccessUseCase(this._repository);

  Future<bool> execute(String courseId, String lessonId) {
    return _repository.checkLessonAccess(courseId, lessonId);
  }
}
