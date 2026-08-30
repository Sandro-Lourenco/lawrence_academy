import 'package:lawrence/core/network/network_client.dart';
import 'package:lawrence/features/tasks/domain/entities/task.dart';
import 'package:lawrence/features/tasks/domain/entities/task_submission.dart';

class TaskRemoteDataSource {
  final NetworkClient _networkClient;

  TaskRemoteDataSource(this._networkClient);

  Future<List<Task>> getMyActivities() async {
    final response = await _networkClient.get<List<dynamic>>(
      '/api/v1/tasks/me',
    );
    return (response.data ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Task.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getTasksAndSubmissionsForLesson(
    String lessonId,
    String courseId,
  ) async {
    final response = await _networkClient.get<Map<String, dynamic>>(
      '/api/v1/tasks/lesson/$lessonId?course_id=$courseId',
    );
    final data = response.data ?? const <String, dynamic>{};
    final tasks = (data['tasks'] as List? ?? const [])
        .map((t) => Task.fromJson(t))
        .toList();
    final submissions = (data['submissions'] as List? ?? const [])
        .map((s) => TaskSubmission.fromJson(s))
        .toList();
    return {'tasks': tasks, 'submissions': submissions};
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
    final response = await _networkClient.post<Map<String, dynamic>>(
      '/api/v1/tasks/$taskId/submissions',
      data: body,
    );
    return TaskSubmission.fromJson(response.data ?? const {});
  }

  Future<Task> createTask({
    required String courseId,
    required String lessonId,
    required String title,
    required String taskType,
    required String description,
    required Map<String, dynamic> options,
    required String? correctOption,
    required int maxAttempts,
    required double passingScore,
  }) async {
    final response = await _networkClient.post<Map<String, dynamic>>(
      '/api/v1/tasks',
      data: {
        'course_id': courseId,
        'lesson_id': lessonId,
        'title': title,
        'task_type': taskType,
        'description': description,
        'options': options,
        'correct_option': correctOption,
        'max_attempts': maxAttempts,
        'passing_score': passingScore,
      },
    );
    final data = response.data?['data'];
    if (data is! Map) {
      throw StateError('O servidor não confirmou a criação da atividade.');
    }
    return Task.fromJson(data.cast<String, dynamic>());
  }

  Future<Task> updateTask(
    String taskId, {
    required String title,
    required String taskType,
    required String description,
    required Map<String, dynamic> options,
    required String? correctOption,
    required int maxAttempts,
    required double passingScore,
  }) async {
    final response = await _networkClient.patch<Map<String, dynamic>>(
      '/api/v1/tasks/$taskId',
      data: {
        'title': title,
        'task_type': taskType,
        'description': description,
        'options': options,
        'correct_option': correctOption,
        'max_attempts': maxAttempts,
        'passing_score': passingScore,
      },
    );
    final data = response.data?['data'];
    if (data is! Map) {
      throw StateError('O servidor não confirmou a atividade.');
    }
    return Task.fromJson(data.cast<String, dynamic>());
  }

  Future<void> deleteTask(String taskId) async {
    await _networkClient.delete<void>('/api/v1/tasks/$taskId');
  }
}
