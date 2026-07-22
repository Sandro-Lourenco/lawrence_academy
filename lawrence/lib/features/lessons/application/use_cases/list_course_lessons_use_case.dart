import '../../domain/entities/lesson_entity.dart';
import '../../domain/repositories/lesson_repository_interface.dart';

class ListCourseLessonsUseCase {
  final ILessonRepository _repository;

  ListCourseLessonsUseCase(this._repository);

  Future<List<LessonEntity>> execute(String courseId) {
    return _repository.getCourseLessons(courseId);
  }
}
