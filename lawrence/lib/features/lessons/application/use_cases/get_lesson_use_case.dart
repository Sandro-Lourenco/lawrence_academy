import '../../domain/entities/lesson_entity.dart';
import '../../domain/repositories/lesson_repository_interface.dart';

class GetLessonUseCase {
  final ILessonRepository _repository;

  GetLessonUseCase(this._repository);

  Future<LessonEntity> execute(String courseId, String lessonId) {
    return _repository.getLesson(courseId, lessonId);
  }
}
