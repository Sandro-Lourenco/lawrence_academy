import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lawrence/data/datasources/supabase_client.dart';
import 'package:lawrence/data/models/course_dto.dart';

class CourseRepository {
  final SupabaseClient _client;

  CourseRepository(this._client);

  /// Retorna o catálogo completo de cursos publicados (Aggregate Root)
  Future<List<Course>> fetchPublishedCourses() async {
    final response = await _client
        .from('courses')
        .select('*, modules(*, lessons(*))')
        .eq('status', 'published');
        
    final data = response as List? ?? [];
    return data.map((json) => Course.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Retorna os detalhes de um curso específico (Aggregate Root)
  Future<Course?> fetchCourseDetails(String courseId) async {
    final response = await _client
        .from('courses')
        .select('*, modules(*, lessons(*))')
        .eq('id', courseId)
        .limit(1)
        .maybeSingle();
        
    if (response == null) return null;
    return Course.fromJson(response as Map<String, dynamic>);
  }

  /// Registra o progresso assistido localmente no Supabase
  Future<void> updateLessonProgress({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required bool completed,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('lesson_progress').upsert({
      'student_id': userId,
      'course_id': courseId,
      'lesson_id': lessonId,
      'watched_seconds': watchedSeconds,
      'completed': completed,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'student_id,lesson_id');
  }

  /// Busca o progresso de uma aula para retomar a reprodução
  Future<Map<String, dynamic>?> fetchLessonProgress(String lessonId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('lesson_progress')
        .select('*')
        .eq('student_id', userId)
        .eq('lesson_id', lessonId)
        .maybeSingle();
        
    return response as Map<String, dynamic>?;
  }

  /// Busca todo o progresso de lições do usuário atual
  Future<List<Map<String, dynamic>>> fetchAllLessonProgress() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('lesson_progress')
        .select('*')
        .eq('student_id', userId);
        
    final data = response as List? ?? [];
    return data.map((json) => json as Map<String, dynamic>).toList();
  }
}

/// Provider do repositório de cursos.
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CourseRepository(client);
});
