import 'package:uuid/uuid.dart';
import 'package:lawrence/features/sync/domain/sync_event.dart';
import 'package:lawrence/features/sync/domain/repositories/queue_repository.dart';

class TelemetryQueue {
  final QueueRepository _repository;
  final Uuid _uuid = const Uuid();

  TelemetryQueue(this._repository);

  Future<void> logEvent({
    required String action,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    final event = SyncEvent(
      id: _uuid.v4(),
      action: action,
      payload: payload,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      idempotencyKey: idempotencyKey,
    );
    await _repository.enqueue(event);
  }

  Future<void> logProgress({
    required String lessonId,
    required String courseId,
    required int progress,
    required int position,
    required String deviceId,
  }) async {
    await logEvent(
      action: 'UPDATE_LESSON_PROGRESS',
      payload: {
        'lesson_id': lessonId,
        'course_id': courseId,
        'progress': progress,
        'position': position,
        'device_id': deviceId,
        'correlation_id': _uuid.v4(),
      },
    );
  }
}
