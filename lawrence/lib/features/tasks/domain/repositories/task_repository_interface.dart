import '../entities/task_submission.dart';

abstract class TaskRepositoryInterface {
  Future<Map<String, dynamic>> getTasksAndSubmissionsForLesson(
    String lessonId,
    String courseId,
  );
  Future<TaskSubmission> submitTask(
    String taskId, {
    String? selectedOption,
    String? textAnswer,
    bool isDraft = false,
    required String idempotencyKey,
  });
}
