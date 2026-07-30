import 'dart:async';
import 'package:lawrence/features/sync/domain/repositories/queue_repository.dart';
import 'package:lawrence/features/sync/domain/sync_event.dart';

class SyncScheduler {
  final QueueRepository _repository;
  final Future<List<String>> Function(List<SyncEvent> events)? sendBatch;
  Timer? _timer;
  bool _isSyncing = false;

  SyncScheduler(this._repository, {this.sendBatch});

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _syncNow());
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _repository.getPendingEvents();
      if (pending.isEmpty) return;

      final batchSender = sendBatch;
      if (batchSender == null) return;

      final acknowledgedIds = (await batchSender(pending)).toSet();
      final pendingIds = pending.map((event) => event.id).toSet();
      final validAcknowledgements = acknowledgedIds.intersection(pendingIds);
      if (validAcknowledgements.isNotEmpty) {
        await _repository.markAsCompleted(validAcknowledgements.toList());
      }
    } catch (_) {
      // Falhas de transporte preservam a fila para uma tentativa posterior.
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncNow() => syncNow();
}
