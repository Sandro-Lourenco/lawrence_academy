abstract interface class ProgressLocalDataSource {
  Future<Map<String, dynamic>?> getProgress(
    String courseId,
    String lessonId,
  );

  Future<List<Map<String, dynamic>>> getCourseProgress(String courseId);

  Future<void> saveProgress(Map<String, dynamic> progress);

  Future<void> enqueueSyncItem(Map<String, dynamic> item);

  Future<List<Map<String, dynamic>>> getPendingSyncItems();

  Future<void> updateSyncItemStatus(
    int id, {
    required String status,
    required int retryCount,
    String? nextRetryAt,
    String? lastError,
  });

  Future<void> deleteSyncItem(int id);
}
