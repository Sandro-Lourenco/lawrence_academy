import 'package:lawrence/features/sync/domain/sync_event.dart';
import 'package:lawrence/features/sync/domain/repositories/queue_repository.dart';

class SQLiteQueueRepository implements QueueRepository {
  // Mocking SQLite implementation for Phase 6D base structure
  final List<SyncEvent> _queue = [];

  @override
  Future<void> enqueue(SyncEvent event) async {
    _queue.add(event);
  }

  @override
  Future<List<SyncEvent>> getPendingEvents({int limit = 100}) async {
    final pending = _queue
        .where((e) => e.status == 'PENDING')
        .take(limit)
        .toList();
    return pending;
  }

  @override
  Future<void> markAsCompleted(List<String> eventIds) async {
    for (int i = 0; i < _queue.length; i++) {
      if (eventIds.contains(_queue[i].id)) {
        _queue[i] = _queue[i].copyWith(status: 'COMPLETED');
      }
    }
  }

  @override
  Future<void> markAsFailed(
    List<String> eventIds, {
    required int nextRetryAt,
  }) async {
    for (int i = 0; i < _queue.length; i++) {
      if (eventIds.contains(_queue[i].id)) {
        _queue[i] = _queue[i].copyWith(
          status: 'FAILED',
          retryCount: _queue[i].retryCount + 1,
          nextRetryAt: nextRetryAt,
        );
      }
    }
  }
}
