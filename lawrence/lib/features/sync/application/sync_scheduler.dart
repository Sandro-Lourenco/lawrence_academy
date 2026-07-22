import 'dart:async';
import 'package:lawrence/features/sync/domain/repositories/queue_repository.dart';

class SyncScheduler {
  final QueueRepository _repository;
  Timer? _timer;
  bool _isSyncing = false;

  SyncScheduler(this._repository);

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _syncNow());
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _repository.getPendingEvents();
      if (pending.isEmpty) return;

      // TODO: Call API endpoint POST /api/v1/offline/sync
      // For now, simulate success
      final successIds = pending.map((e) => e.id).toList();

      await _repository.markAsCompleted(successIds);
    } catch (e) {
      // Exponential backoff logic would go here
    } finally {
      _isSyncing = false;
    }
  }
}
