import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_submission.dart';
import '../../domain/repositories/task_repository_interface.dart';
import 'package:uuid/uuid.dart';

enum TaskExecutionStateStatus {
  loading,
  editing,
  validating,
  sending,
  success,
  error,
  unauthorized,
}

class TaskExecutionState {
  final TaskExecutionStateStatus status;
  final List<Task> tasks;
  final List<TaskSubmission> submissions;
  final String? errorMessage;

  TaskExecutionState({
    required this.status,
    this.tasks = const [],
    this.submissions = const [],
    this.errorMessage,
  });

  TaskExecutionState copyWith({
    TaskExecutionStateStatus? status,
    List<Task>? tasks,
    List<TaskSubmission>? submissions,
    String? errorMessage,
  }) {
    return TaskExecutionState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      submissions: submissions ?? this.submissions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TaskExecutionController extends StateNotifier<TaskExecutionState> {
  final TaskRepositoryInterface _repository;

  TaskExecutionController(this._repository)
    : super(TaskExecutionState(status: TaskExecutionStateStatus.loading));

  Future<void> loadTasks(String lessonId, String courseId) async {
    state = state.copyWith(status: TaskExecutionStateStatus.loading);
    try {
      final data = await _repository.getTasksAndSubmissionsForLesson(
        lessonId,
        courseId,
      );
      state = state.copyWith(
        status: TaskExecutionStateStatus.editing,
        tasks: data['tasks'],
        submissions: data['submissions'],
      );
    } catch (e) {
      state = state.copyWith(
        status: TaskExecutionStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> submitTask(
    String taskId, {
    String? selectedOption,
    String? textAnswer,
    bool isDraft = false,
  }) async {
    state = state.copyWith(status: TaskExecutionStateStatus.sending);
    try {
      final idempotencyKey = const Uuid().v4();
      final submission = await _repository.submitTask(
        taskId,
        selectedOption: selectedOption,
        textAnswer: textAnswer,
        isDraft: isDraft,
        idempotencyKey: idempotencyKey,
      );

      final updatedSubmissions = List<TaskSubmission>.from(state.submissions)
        ..removeWhere((s) => s.taskId == taskId)
        ..add(submission);

      state = state.copyWith(
        status: TaskExecutionStateStatus.success,
        submissions: updatedSubmissions,
      );
    } catch (e) {
      state = state.copyWith(
        status: TaskExecutionStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void resetStatus() {
    if (state.status == TaskExecutionStateStatus.success ||
        state.status == TaskExecutionStateStatus.error) {
      state = state.copyWith(status: TaskExecutionStateStatus.editing);
    }
  }
}
