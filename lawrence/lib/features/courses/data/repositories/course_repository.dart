import '../../../../core/network/network_client.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository_interface.dart';

class CourseRepository implements ICourseRepository {
  final NetworkClient _networkClient;

  CourseRepository(this._networkClient);

  @override
  Future<List<Course>> fetchPublishedCourses() async {
    final response = await _networkClient.get<List<dynamic>>('/api/v1/courses');
    final data = response.data ?? [];
    return data
        .map((json) => Course.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Course?> fetchCourseDetails(String courseId) async {
    final response = await _networkClient.get<Map<String, dynamic>>(
      '/api/v1/courses/$courseId',
    );
    final data = response.data;
    if (data == null) return null;
    return Course.fromJson(data);
  }

  @override
  Future<Course?> fetchCourseBySlug(String slug) async {
    final response = await _networkClient.get<Map<String, dynamic>>(
      '/api/v1/courses/slug/$slug',
    );
    final data = response.data;
    if (data == null) return null;
    return Course.fromJson(data);
  }
}
