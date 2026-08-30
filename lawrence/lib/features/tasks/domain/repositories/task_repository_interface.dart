import '../entities/task_submission.dart';
import '../entities/task.dart';

abstract class TaskRepositoryInterface {
  Future<List<Task>> getMyActivities();
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
  });
  Future<Task> updateTask(
    String taskId, {
    required String title,
    required String taskType,
    required String description,
    required Map<String, dynamic> options,
    required String? correctOption,
    required int maxAttempts,
    required double passingScore,
  });
  Future<void> deleteTask(String taskId);
}
