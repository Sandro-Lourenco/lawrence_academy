import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/sync/application/sync_scheduler.dart';
import 'package:lawrence/features/sync/data/queue_repository.dart';
import 'package:lawrence/features/sync/domain/sync_event.dart';

void main() {
  SyncEvent event(String id) => SyncEvent(
    id: id,
    action: 'UPDATE_LESSON_PROGRESS',
    payload: const {'lesson_id': 'lesson-1', 'watched_seconds': 30},
    createdAt: 1,
  );

  test('keeps events pending when no transport is configured', () async {
    final repository = SQLiteQueueRepository();
    await repository.enqueue(event('event-1'));

    await SyncScheduler(repository).syncNow();

    expect(await repository.getPendingEvents(), hasLength(1));
  });

  test('completes only events acknowledged by the transport', () async {
    final repository = SQLiteQueueRepository();
    await repository.enqueue(event('event-1'));
    await repository.enqueue(event('event-2'));
    final scheduler = SyncScheduler(
      repository,
      sendBatch: (_) async => ['event-1', 'unknown-event'],
    );

    await scheduler.syncNow();

    final pending = await repository.getPendingEvents();
    expect(pending.map((item) => item.id), ['event-2']);
  });

  test('keeps events pending when transport fails', () async {
    final repository = SQLiteQueueRepository();
    await repository.enqueue(event('event-1'));
    final scheduler = SyncScheduler(
      repository,
      sendBatch: (_) => Future<List<String>>.error(Exception('offline')),
    );

    await scheduler.syncNow();

    expect(await repository.getPendingEvents(), hasLength(1));
  });
}
