import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository_interface.dart';

class ListCoursesUseCase {
  final ICourseRepository _courseRepository;

  ListCoursesUseCase(this._courseRepository);

  Future<List<Course>> execute() {
    return _courseRepository.fetchPublishedCourses();
  }
}
