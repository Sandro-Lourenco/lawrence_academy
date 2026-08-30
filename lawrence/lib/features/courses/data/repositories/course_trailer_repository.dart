import '../../../../core/network/network_client.dart';

class CourseTrailerRepository {
  const CourseTrailerRepository(this._networkClient);

  final NetworkClient _networkClient;

  Future<String> fetchStreamUrl(String courseId) async {
    final response = await _networkClient.get<Map<String, dynamic>>(
      '/api/v1/courses/$courseId/trailer/stream',
    );
    final relativeUrl = response.data?['signedUrl'] as String?;
    if (relativeUrl == null || relativeUrl.isEmpty) {
      throw StateError('O trailer não retornou uma URL de reprodução.');
    }
    return _networkClient.resolveUrl(relativeUrl);
  }
}
