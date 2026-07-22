import '../../domain/repositories/task_repository_interface.dart';
import '../../domain/entities/task_submission.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepositoryInterface {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

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
}
