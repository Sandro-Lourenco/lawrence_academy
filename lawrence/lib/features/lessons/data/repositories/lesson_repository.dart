import '../../../../core/network/network_client.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/repositories/lesson_repository_interface.dart';
import '../models/lesson_api_model.dart';
import '../mappers/lesson_mapper.dart';

class LessonRepository implements ILessonRepository {
  final NetworkClient _networkClient;

  LessonRepository(this._networkClient);

  @override
  Future<LessonEntity> getLesson(String courseId, String lessonId) async {
    final response = await _networkClient.get(
      '/api/v1/courses/$courseId/lessons/$lessonId',
    );
    final model = LessonApiModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    return LessonMapper.toEntity(model);
  }

  @override
  Future<List<LessonEntity>> getCourseLessons(String courseId) async {
    // Busca os detalhes do curso para obter a árvore de módulos e lições
    final response = await _networkClient.get('/api/v1/courses/$courseId');
    final modules = response.data['modules'] as List? ?? [];
    final List<LessonEntity> lessons = [];

    for (final module in modules) {
      final lessonsJson = module['lessons'] as List? ?? [];
      for (final lessonJson in lessonsJson) {
        final model = LessonApiModel.fromJson(
          lessonJson as Map<String, dynamic>,
        );
        lessons.add(LessonMapper.toEntity(model));
      }
    }
    return lessons;
  }

  @override
  Future<String> getLessonStreamUrl(String courseId, String lessonId) async {
    final response = await _networkClient.get(
      '/api/v1/courses/$courseId/lessons/$lessonId/stream',
    );
    return response.data['signedUrl'] as String;
  }

  @override
  Future<bool> checkLessonAccess(String courseId, String lessonId) async {
    try {
      await getLessonStreamUrl(courseId, lessonId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
