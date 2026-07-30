import 'dart:async';

class LessonProgressSyncCoordinator {
  final Future<void> Function() synchronizeCallback;
  final Duration interval;

  Timer? _timer;
  bool _isSynchronizing = false;

  LessonProgressSyncCoordinator({
    required this.synchronizeCallback,
    this.interval = const Duration(minutes: 1),
  });

  void start() {
    _timer?.cancel();
    unawaited(synchronizeNow());
    _timer = Timer.periodic(interval, (_) => unawaited(synchronizeNow()));
  }

  Future<void> synchronizeNow() async {
    if (_isSynchronizing) return;
    _isSynchronizing = true;
    try {
      await synchronizeCallback();
    } catch (_) {
      // A fila persistente mantém os eventos e o backoff para a próxima rodada.
    } finally {
      _isSynchronizing = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
