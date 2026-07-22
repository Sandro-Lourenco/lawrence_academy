import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository_interface.dart';

class GetCourseDetailUseCase {
  final ICourseRepository _courseRepository;

  GetCourseDetailUseCase(this._courseRepository);

  Future<Course?> executeWithId(String id) {
    return _courseRepository.fetchCourseDetails(id);
  }

  Future<Course?> executeWithSlug(String slug) {
    return _courseRepository.fetchCourseBySlug(slug);
  }
}
