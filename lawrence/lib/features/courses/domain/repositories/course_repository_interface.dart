import '../entities/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> fetchPublishedCourses();
  Future<Course?> fetchCourseDetails(String courseId);
  Future<Course?> fetchCourseBySlug(String slug);
}
