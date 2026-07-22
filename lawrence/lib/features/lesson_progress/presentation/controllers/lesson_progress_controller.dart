import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/learning_repositories.dart';
import '../../application/use_cases/sync_lesson_progress_use_case.dart';
import '../../application/use_cases/update_lesson_progress_use_case.dart';
import '../../application/use_cases/resolve_progress_conflict_use_case.dart';
import '../../domain/entities/lesson_progress_entity.dart';

final updateLessonProgressUseCaseProvider =
    Provider<UpdateLessonProgressUseCase>((ref) {
      final repo = ref.watch(lessonProgressRepositoryProvider);
      return UpdateLessonProgressUseCase(repo);
    });

final syncLessonProgressUseCaseProvider = Provider<SyncLessonProgressUseCase>((
  ref,
) {
  final repo = ref.watch(lessonProgressRepositoryProvider);
  return SyncLessonProgressUseCase(repo);
});

final resolveProgressConflictUseCaseProvider =
    Provider<ResolveProgressConflictUseCase>((ref) {
      return ResolveProgressConflictUseCase();
    });

// Provider para obter o progresso de uma lição específica
final lessonProgressProvider = FutureProvider.autoDispose
    .family<LessonProgressEntity?, ({String courseId, String lessonId})>((
      ref,
      arg,
    ) async {
      final repo = ref.watch(lessonProgressRepositoryProvider);
      return await repo.getProgress(arg.courseId, arg.lessonId);
    });

// Provider para obter o progresso de todas as lições de um curso
final courseProgressListProvider = FutureProvider.autoDispose
    .family<List<LessonProgressEntity>, String>((ref, courseId) async {
      final repo = ref.watch(lessonProgressRepositoryProvider);
      return await repo.getCourseProgress(courseId);
    });

class LessonProgressController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LessonProgressController(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateProgress({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required double progressPercentage,
    required bool completed,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updateUseCase = _ref.read(updateLessonProgressUseCaseProvider);
      await updateUseCase.execute(
        courseId: courseId,
        lessonId: lessonId,
        watchedSeconds: watchedSeconds,
        progressPercentage: progressPercentage,
        completed: completed,
      );

      // Tenta sincronizar de forma assíncrona
      final syncUseCase = _ref.read(syncLessonProgressUseCaseProvider);
      syncUseCase.execute().catchError((_) {});
    });
  }

  Future<void> syncQueue() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final syncUseCase = _ref.read(syncLessonProgressUseCaseProvider);
      await syncUseCase.execute();
    });
  }
}

final lessonProgressControllerProvider =
    StateNotifierProvider<LessonProgressController, AsyncValue<void>>((ref) {
      return LessonProgressController(ref);
    });
