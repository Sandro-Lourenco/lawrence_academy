import '../sync_event.dart';

abstract interface class QueueRepository {
  Future<void> enqueue(SyncEvent event);

  Future<List<SyncEvent>> getPendingEvents({int limit = 100});

  Future<void> markAsCompleted(List<String> eventIds);

  Future<void> markAsFailed(List<String> eventIds, {required int nextRetryAt});
}
