import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/activity.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../../tasks/domain/entities/task.dart';

typedef ActivitiesLoader = Future<List<Activity>> Function();

final activitiesLoaderProvider = Provider<ActivitiesLoader>(
  (ref) => () async {
    final tasks = await ref.read(taskRepositoryProvider).getMyActivities();
    return tasks.map(_activityFromTask).toList(growable: false);
  },
);

Activity _activityFromTask(Task task) {
  final submission = task.latestSubmission;
  final status = switch (submission?.status) {
    'draft' => ActivityStatus.inProgress,
    'pending_review' => ActivityStatus.submitted,
    'graded' => ActivityStatus.graded,
    _ => ActivityStatus.pending,
  };
  final type = switch (task.type) {
    'multiple_choice' => ActivityType.quiz,
    'true_false' => ActivityType.trueFalse,
    'essay' => ActivityType.essay,
    _ => ActivityType.essay,
  };
  return Activity(
    id: task.id,
    title: task.title,
    courseName: task.courseName ?? 'Curso',
    teacherName: task.teacherName ?? 'Lawrence Academy',
    type: type,
    status: status,
    grade: submission?.score,
    feedback: submission?.teacherFeedback,
    courseId: task.courseId,
    lessonId: task.lessonId,
    description: task.description,
    options: task.options,
    maxAttempts: task.maxAttempts,
    attemptsUsed: task.attemptsUsed,
    selectedOption: submission?.selectedOption,
    textAnswer: submission?.textAnswer,
    correctOption: submission?.correctOption,
    isCorrect: submission?.isCorrect,
  );
}

class ActivitiesState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;

  ActivitiesState({
    required this.activities,
    this.isLoading = false,
    this.error,
  });

  ActivitiesState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return ActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ActivitiesNotifier extends StateNotifier<AsyncValue<List<Activity>>> {
  final ActivitiesLoader _load;

  ActivitiesNotifier(this._load) : super(const AsyncValue.loading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _load());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final activitiesNotifierProvider =
    StateNotifierProvider<ActivitiesNotifier, AsyncValue<List<Activity>>>((
      ref,
    ) {
      return ActivitiesNotifier(ref.watch(activitiesLoaderProvider));
    });
