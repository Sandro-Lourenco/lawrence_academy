import 'dart:convert';
import 'package:lawrence/core/services/api_service.dart'; // Assume ApiService is available for base url and auth headers
import 'package:lawrence/features/tasks/domain/entities/task.dart';
import 'package:lawrence/features/tasks/domain/entities/task_submission.dart';

class TaskRemoteDataSource {
  final ApiService _apiService;

  TaskRemoteDataSource(this._apiService);

  Future<Map<String, dynamic>> getTasksAndSubmissionsForLesson(
    String lessonId,
    String courseId,
  ) async {
    final response = await _apiService.get(
      '/api/v1/tasks/lesson/$lessonId?course_id=$courseId',
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tasks = (data['tasks'] as List)
          .map((t) => Task.fromJson(t))
          .toList();
      final submissions = (data['submissions'] as List)
          .map((s) => TaskSubmission.fromJson(s))
          .toList();
      return {'tasks': tasks, 'submissions': submissions};
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<TaskSubmission> submitTask(
    String taskId, {
    String? selectedOption,
    String? textAnswer,
    bool isDraft = false,
    required String idempotencyKey,
  }) async {
    final body = {
      'selected_option': selectedOption,
      'text_answer': textAnswer,
      'is_draft': isDraft,
      'idempotency_key': idempotencyKey,
    };
    final response = await _apiService.post(
      '/api/v1/tasks/$taskId/submissions',
      body: body,
    );
    if (response.statusCode == 201) {
      return TaskSubmission.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit task');
    }
  }
}
