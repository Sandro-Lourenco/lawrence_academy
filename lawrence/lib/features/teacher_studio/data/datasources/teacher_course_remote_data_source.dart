import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_client.dart';
import '../../../../features/courses/domain/entities/course.dart';

abstract class ITeacherCourseRemoteDataSource {
  Future<List<Course>> getTeacherCourses();
  Future<Course> getTeacherCourse(String courseId);
  Future<Course> createCourse(Map<String, dynamic> data);
  Future<Course> updateCourse(String courseId, Map<String, dynamic> data);
  Future<void> deleteCourse(String courseId);
  Future<Module> createModule(String courseId, Map<String, dynamic> data);
  Future<Module> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  );
  Future<void> deleteModule(String courseId, String moduleId);
  Future<Lesson> createLesson(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  );
  Future<Lesson> updateLesson(
    String courseId,
    String lessonId,
    Map<String, dynamic> data,
  );
  Future<void> deleteLesson(String courseId, String lessonId);
  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required String filePath,
    required String filename,
    required int sizeBytes,
    required String contentType,
  });
}

class TeacherCourseRemoteDataSource implements ITeacherCourseRemoteDataSource {
  final NetworkClient _client;
  final SupabaseClient _supabase;

  TeacherCourseRemoteDataSource(this._client, this._supabase);

  @override
  Future<List<Course>> getTeacherCourses() async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/teacher/courses',
    );
    final data = response.data ?? [];
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Lesson> updateLesson(
    String courseId,
    String lessonId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId',
      data: data,
    );
    if (response.data == null) throw Exception('Falha ao atualizar aula.');
    return Lesson.fromJson(response.data!);
  }

  @override
  Future<void> deleteLesson(String courseId, String lessonId) async {
    await _client.delete<dynamic>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId',
    );
  }

  @override
  Future<Course> getTeacherCourse(String courseId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId',
    );
    if (response.data == null) throw Exception("Course not found");
    return Course.fromJson(response.data!);
  }

  @override
  Future<Course> createCourse(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses',
      data: data,
    );
    if (response.data == null) throw Exception("Failed to create course");
    return Course.fromJson(response.data!);
  }

  @override
  Future<Course> updateCourse(
    String courseId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId',
      data: data,
    );
    if (response.data == null) throw Exception("Failed to update course");
    return Course.fromJson(response.data!);
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _client.delete<dynamic>('/api/v1/teacher/courses/$courseId');
  }

  @override
  Future<Module> createModule(
    String courseId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/modules',
      data: data,
    );
    if (response.data == null) throw Exception("Failed to create module");
    return Module.fromJson(response.data!);
  }

  @override
  Future<Module> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/modules/$moduleId',
      data: data,
    );
    if (response.data == null) throw Exception("Failed to update module");
    return Module.fromJson(response.data!);
  }

  @override
  Future<void> deleteModule(String courseId, String moduleId) async {
    await _client.delete<dynamic>(
      '/api/v1/teacher/courses/$courseId/modules/$moduleId',
    );
  }

  @override
  Future<Lesson> createLesson(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/modules/$moduleId/lessons',
      data: data,
    );
    if (response.data == null) throw Exception('Falha ao criar aula.');
    return Lesson.fromJson(response.data!);
  }

  @override
  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required String filePath,
    required String filename,
    required int sizeBytes,
    required String contentType,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/upload',
      data: {
        'filename': filename,
        'content_type': contentType,
        'size_bytes': sizeBytes,
      },
    );
    final data = response.data;
    if (data == null) throw Exception('URL de upload nÃ£o retornada.');
    final path = data['path'] as String?;
    final signedUrl = data['signed_url'] as String?;
    final token = signedUrl == null
        ? null
        : Uri.parse(signedUrl).queryParameters['token'];
    if (path == null || token == null || token.isEmpty) {
      throw Exception('Resposta de upload invÃ¡lida.');
    }
    await _supabase.storage
        .from('raw-videos')
        .uploadToSignedUrl(
          path,
          token,
          File(filePath),
          FileOptions(contentType: contentType, upsert: false),
        );
  }
}
