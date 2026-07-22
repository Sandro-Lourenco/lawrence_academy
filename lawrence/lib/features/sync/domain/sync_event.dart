class SyncEvent {
  final String id;
  final String action;
  final Map<String, dynamic> payload;
  final int createdAt;
  final String? idempotencyKey;
  final String status;
  final int retryCount;
  final int? nextRetryAt;

  const SyncEvent({
    required this.id,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.idempotencyKey,
    this.status = 'PENDING',
    this.retryCount = 0,
    this.nextRetryAt,
  });

  SyncEvent copyWith({
    String? id,
    String? action,
    Map<String, dynamic>? payload,
    int? createdAt,
    String? idempotencyKey,
    String? status,
    int? retryCount,
    int? nextRetryAt,
  }) {
    return SyncEvent(
      id: id ?? this.id,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    return SyncEvent(
      id: json['id'] as String,
      action: json['action'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      createdAt: json['createdAt'] as int,
      idempotencyKey: json['idempotencyKey'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      retryCount: json['retryCount'] as int? ?? 0,
      nextRetryAt: json['nextRetryAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'payload': payload,
      'createdAt': createdAt,
      'idempotencyKey': idempotencyKey,
      'status': status,
      'retryCount': retryCount,
      'nextRetryAt': nextRetryAt,
    };
  }
}
