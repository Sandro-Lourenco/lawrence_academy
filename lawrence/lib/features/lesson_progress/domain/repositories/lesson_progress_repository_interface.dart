import '../entities/lesson_progress_entity.dart';
import '../entities/sync_queue_item.dart';

abstract class ILessonProgressRepository {
  Future<LessonProgressEntity?> getProgress(String courseId, String lessonId);
  Future<List<LessonProgressEntity>> getCourseProgress(String courseId);
  Future<void> saveProgressLocally(LessonProgressEntity progress);
  Future<void> syncProgressWithServer(
    LessonProgressEntity progress,
    String idempotencyKey,
  );
  Future<List<SyncQueueItem>> getPendingSyncItems();
  Future<void> processSyncQueue();
  Future<List<LessonProgressEntity>> fetchAllRemoteProgress();
}
