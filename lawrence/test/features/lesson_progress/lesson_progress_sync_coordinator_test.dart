import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/lesson_progress/application/lesson_progress_sync_coordinator.dart';

void main() {
  test('start performs an immediate synchronization', () async {
    var calls = 0;
    final synchronized = Completer<void>();
    final coordinator = LessonProgressSyncCoordinator(
      synchronizeCallback: () async {
        calls++;
        synchronized.complete();
      },
      interval: const Duration(hours: 1),
    );

    coordinator.start();
    await synchronized.future;
    coordinator.dispose();

    expect(calls, 1);
  });

  test('does not overlap synchronization rounds', () async {
    var calls = 0;
    final release = Completer<void>();
    final coordinator = LessonProgressSyncCoordinator(
      synchronizeCallback: () async {
        calls++;
        await release.future;
      },
    );

    final first = coordinator.synchronizeNow();
    await Future<void>.delayed(Duration.zero);
    await coordinator.synchronizeNow();
    expect(calls, 1);

    release.complete();
    await first;
    coordinator.dispose();
  });

  test('a transport failure does not block the next round', () async {
    var calls = 0;
    final coordinator = LessonProgressSyncCoordinator(
      synchronizeCallback: () async {
        calls++;
        if (calls == 1) throw Exception('offline');
      },
    );

    await coordinator.synchronizeNow();
    await coordinator.synchronizeNow();
    coordinator.dispose();

    expect(calls, 2);
  });
}
