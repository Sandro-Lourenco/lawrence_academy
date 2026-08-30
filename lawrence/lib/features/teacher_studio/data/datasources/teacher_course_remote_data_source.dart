import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_client.dart';
import '../../../../features/courses/domain/entities/course.dart';
import '../../domain/entities/upload_file_payload.dart';
import '../../domain/entities/teacher_course_student.dart';
import 'signed_storage_uploader.dart';

abstract class ITeacherCourseRemoteDataSource {
  Future<List<Course>> getTeacherCourses();
  Future<Course> getTeacherCourse(String courseId);
  Future<List<TeacherCourseStudent>> getCourseStudents(String courseId);
  Future<Course> createCourse(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<Course> updateCourse(String courseId, Map<String, dynamic> data);
  Future<void> deleteCourse(String courseId, {String? reason});
  Future<Module> createModule(
    String courseId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<Module> updateModule(
    String courseId,
    String moduleId,
    Map<String, dynamic> data,
  );
  Future<void> deleteModule(String courseId, String moduleId);
  Future<Lesson> createLesson(
    String courseId,
    String moduleId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<Lesson> updateLesson(
    String courseId,
    String lessonId,
    Map<String, dynamic> data,
  );
  Future<void> deleteLesson(String courseId, String lessonId);
  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
    required String idempotencyKey,
  });
  Future<void> uploadCourseMedia({
    required String courseId,
    required String assetType,
    required UploadFilePayload file,
    String altText = '',
  });
  Future<LessonBlock> createLessonBlock(
    String courseId,
    String lessonId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<List<LessonBlock>> listLessonBlocks(String courseId, String lessonId);
  Future<LessonBlock> updateLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
    Map<String, dynamic> data,
  );
  Future<LessonBlock> duplicateLessonBlock(
    String courseId,
    String lessonId,
    String blockId, {
    required String idempotencyKey,
  });
  Future<void> deleteLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
  );
  Future<Map<String, String>> uploadLessonAsset({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
  });
  Future<Map<String, dynamic>> getPublicationChecklist(String courseId);
  Future<Course> publishCourse(
    String courseId, {
    required String idempotencyKey,
  });
  Future<List<Map<String, dynamic>>> getCourseVersions(String courseId);
  Future<Map<String, dynamic>> getCourseVersion(
    String courseId,
    String versionId,
  );
  Future<Course> restoreCourseVersion(
    String courseId,
    String versionId, {
    required String expectedAuthoringUpdatedAt,
    String? reason,
  });
  Future<void> unpublishCourse(String courseId, {String? reason});
  Future<void> restoreCourse(String courseId, {String? reason});
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
  Future<List<TeacherCourseStudent>> getCourseStudents(String courseId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/teacher/courses/$courseId/students',
    );
    return (response.data ?? const [])
        .map(
          (item) => TeacherCourseStudent.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<Course> createCourse(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses',
      data: data,
      options: _idempotencyOptions(idempotencyKey),
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
  Future<void> deleteCourse(String courseId, {String? reason}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/archive',
      data: {'reason': reason ?? 'Arquivado pelo professor'},
    );
  }

  @override
  Future<Module> createModule(
    String courseId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/modules',
      data: data,
      options: _idempotencyOptions(idempotencyKey),
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
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/modules/$moduleId/lessons',
      data: data,
      options: _idempotencyOptions(idempotencyKey),
    );
    if (response.data == null) throw Exception('Falha ao criar aula.');
    return Lesson.fromJson(response.data!);
  }

  @override
  Future<void> uploadLessonVideo({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/upload',
      data: {
        'filename': file.filename,
        'content_type': file.contentType,
        'size_bytes': file.sizeBytes,
        'idempotency_key': idempotencyKey,
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
    await uploadWithSignedToken(
      client: _supabase,
      bucket: 'raw-videos',
      storagePath: path,
      token: token,
      file: file,
    );
  }

  @override
  Future<void> uploadCourseMedia({
    required String courseId,
    required String assetType,
    required UploadFilePayload file,
    String altText = '',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/media/upload',
      data: {
        'asset_type': assetType,
        'filename': file.filename,
        'content_type': file.contentType,
        'size_bytes': file.sizeBytes,
        'alt_text': altText,
      },
    );
    final data = response.data;
    final path = data?['path'] as String?;
    final bucket = data?['bucket'] as String?;
    final signedUrl = data?['signed_url'] as String?;
    final token = signedUrl == null
        ? null
        : Uri.parse(signedUrl).queryParameters['token'];
    if (path == null || bucket == null || token == null || token.isEmpty) {
      throw Exception('Resposta de upload de mídia inválida.');
    }
    await uploadWithSignedToken(
      client: _supabase,
      bucket: bucket,
      storagePath: path,
      token: token,
      file: file,
    );
  }

  @override
  Future<LessonBlock> createLessonBlock(
    String courseId,
    String lessonId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/blocks',
      data: data,
      options: _idempotencyOptions(idempotencyKey),
    );
    return LessonBlock.fromJson(response.data!);
  }

  @override
  Future<List<LessonBlock>> listLessonBlocks(
    String courseId,
    String lessonId,
  ) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/blocks',
    );
    return (response.data ?? const [])
        .map((item) => LessonBlock.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LessonBlock> updateLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/blocks/$blockId',
      data: data,
    );
    return LessonBlock.fromJson(response.data!);
  }

  @override
  Future<LessonBlock> duplicateLessonBlock(
    String courseId,
    String lessonId,
    String blockId, {
    required String idempotencyKey,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/blocks/$blockId/duplicate',
      options: _idempotencyOptions(idempotencyKey),
    );
    return LessonBlock.fromJson(response.data!);
  }

  @override
  Future<void> deleteLessonBlock(
    String courseId,
    String lessonId,
    String blockId,
  ) async {
    await _client.delete<dynamic>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/blocks/$blockId',
    );
  }

  @override
  Future<Map<String, String>> uploadLessonAsset({
    required String courseId,
    required String lessonId,
    required UploadFilePayload file,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/lessons/$lessonId/assets/upload',
      data: {
        'filename': file.filename,
        'content_type': file.contentType,
        'size_bytes': file.sizeBytes,
      },
    );
    final data = response.data;
    final path = data?['path'] as String?;
    final bucket = data?['bucket'] as String?;
    final signed = data?['signed_url'] as String?;
    final token = signed == null
        ? null
        : Uri.parse(signed).queryParameters['token'];
    if (path == null || bucket == null || token == null) {
      throw Exception('Autorização de upload inválida.');
    }
    await uploadWithSignedToken(
      client: _supabase,
      bucket: bucket,
      storagePath: path,
      token: token,
      file: file,
    );
    return {
      'storage_path': path,
      'filename': file.filename,
      'content_type': file.contentType,
    };
  }

  @override
  Future<Map<String, dynamic>> getPublicationChecklist(String courseId) async =>
      (await _client.get<Map<String, dynamic>>(
        '/api/v1/teacher/courses/$courseId/publication-checklist',
      )).data!;
  @override
  Future<Course> publishCourse(
    String courseId, {
    required String idempotencyKey,
  }) async => Course.fromJson(
    (await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/publish',
      options: _idempotencyOptions(idempotencyKey),
    )).data!,
  );
  @override
  Future<List<Map<String, dynamic>>> getCourseVersions(String courseId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/teacher/courses/$courseId/versions',
    );
    return (response.data ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getCourseVersion(
    String courseId,
    String versionId,
  ) async => (await _client.get<Map<String, dynamic>>(
    '/api/v1/teacher/courses/$courseId/versions/$versionId',
  )).data!;

  @override
  Future<Course> restoreCourseVersion(
    String courseId,
    String versionId, {
    required String expectedAuthoringUpdatedAt,
    String? reason,
  }) async => Course.fromJson(
    (await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/versions/$versionId/restore',
      data: {
        'expected_authoring_updated_at': expectedAuthoringUpdatedAt,
        'reason': reason,
      },
    )).data!,
  );

  @override
  Future<void> unpublishCourse(String courseId, {String? reason}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/unpublish',
      data: {'reason': reason},
    );
  }

  @override
  Future<void> restoreCourse(String courseId, {String? reason}) async {
    await _client.post<Map<String, dynamic>>(
      '/api/v1/teacher/courses/$courseId/restore',
      data: {'reason': reason},
    );
  }
}

Options _idempotencyOptions(String key) =>
    Options(headers: {'Idempotency-Key': key});
