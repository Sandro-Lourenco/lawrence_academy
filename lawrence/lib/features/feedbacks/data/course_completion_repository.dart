import '../../../core/network/network_client.dart';
import '../domain/entities/course_completion.dart';

class CourseCompletionRepository {
  const CourseCompletionRepository(this._client);

  final NetworkClient _client;

  Future<CourseCompletion> getCompletion(String courseId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/courses/$courseId/completion',
    );
    return CourseCompletion.fromJson(response.data!);
  }

  Future<CourseCompletion> completeLearnMore({
    required String courseId,
    required String lessonId,
    required String blockId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/courses/$courseId/lessons/$lessonId/learn-more/$blockId/complete',
    );
    return CourseCompletion.fromJson(response.data!);
  }

  Future<CourseFeedback> submitReview({
    required String courseId,
    required int rating,
    required String title,
    required String comment,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/courses/$courseId/reviews',
      data: {'rating': rating, 'title': title, 'comment': comment},
    );
    return CourseFeedback.fromJson(response.data!);
  }

  Future<List<CourseFeedback>> listFeedbacks() async {
    final response = await _client.get<List<dynamic>>('/api/v1/feedbacks');
    return (response.data ?? const [])
        .map((item) => CourseFeedback.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
