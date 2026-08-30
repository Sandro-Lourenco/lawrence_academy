import '../../domain/repositories/task_repository_interface.dart';
import '../../domain/entities/task_submission.dart';
import '../datasources/task_remote_datasource.dart';
import '../../domain/entities/task.dart';

class TaskRepositoryImpl implements TaskRepositoryInterface {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Task>> getMyActivities() => _remoteDataSource.getMyActivities();

  @override
  Future<Map<String, dynamic>> getTasksAndSubmissionsForLesson(
    String lessonId,
    String courseId,
  ) {
    return _remoteDataSource.getTasksAndSubmissionsForLesson(
      lessonId,
      courseId,
    );
  }

  @override
  Future<TaskSubmission> submitTask(
    String taskId, {
    String? selectedOption,
    String? textAnswer,
    bool isDraft = false,
    required String idempotencyKey,
  }) {
    return _remoteDataSource.submitTask(
      taskId,
      selectedOption: selectedOption,
      textAnswer: textAnswer,
      isDraft: isDraft,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
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
  }) => _remoteDataSource.createTask(
    courseId: courseId,
    lessonId: lessonId,
    title: title,
    taskType: taskType,
    description: description,
    options: options,
    correctOption: correctOption,
    maxAttempts: maxAttempts,
    passingScore: passingScore,
  );

  @override
  Future<Task> updateTask(
    String taskId, {
    required String title,
    required String taskType,
    required String description,
    required Map<String, dynamic> options,
    required String? correctOption,
    required int maxAttempts,
    required double passingScore,
  }) => _remoteDataSource.updateTask(
    taskId,
    title: title,
    taskType: taskType,
    description: description,
    options: options,
    correctOption: correctOption,
    maxAttempts: maxAttempts,
    passingScore: passingScore,
  );

  @override
  Future<void> deleteTask(String taskId) =>
      _remoteDataSource.deleteTask(taskId);
}
