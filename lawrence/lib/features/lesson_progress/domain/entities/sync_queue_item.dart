class SyncQueueItem {
  final int? id;
  final String operationType;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final String status;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncQueueItem({
    this.id,
    required this.operationType,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.idempotencyKey,
    required this.status,
    required this.retryCount,
    this.nextRetryAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
}
