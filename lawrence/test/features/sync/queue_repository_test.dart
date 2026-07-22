import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/sync/data/queue_repository.dart';
import 'package:lawrence/features/sync/domain/sync_event.dart';

void main() {
  test('queue preserves pending, completed, and failed transitions', () async {
    final repository = SQLiteQueueRepository();
    final first = SyncEvent(
      id: 'event-1',
      action: 'UPDATE_LESSON_PROGRESS',
      payload: const {'lesson_id': 'lesson-1'},
      createdAt: 1,
    );
    final second = SyncEvent(
      id: 'event-2',
      action: 'UPDATE_LESSON_PROGRESS',
      payload: const {'lesson_id': 'lesson-2'},
      createdAt: 2,
    );

    await repository.enqueue(first);
    await repository.enqueue(second);
    expect(await repository.getPendingEvents(limit: 1), hasLength(1));

    await repository.markAsCompleted([first.id]);
    await repository.markAsFailed([second.id], nextRetryAt: 30);

    expect(await repository.getPendingEvents(), isEmpty);
  });
}
