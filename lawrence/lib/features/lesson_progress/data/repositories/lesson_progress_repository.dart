import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/network_client.dart';
import '../../domain/entities/lesson_progress_entity.dart';
import '../../domain/entities/sync_queue_item.dart';
import '../../domain/repositories/lesson_progress_repository_interface.dart';
import '../datasources/sqlite_progress_datasource.dart';
import '../mappers/lesson_progress_mapper.dart';

class LessonProgressRepository implements ILessonProgressRepository {
  final SQLiteProgressDataSource _localDataSource;
  final NetworkClient _networkClient;
  final Future<String> Function() _getInstallationId;

  LessonProgressRepository(
    this._localDataSource,
    this._networkClient,
    this._getInstallationId,
  );

  @override
  Future<LessonProgressEntity?> getProgress(
    String courseId,
    String lessonId,
  ) async {
    final map = await _localDataSource.getProgress(courseId, lessonId);
    if (map != null) {
      return LessonProgressMapper.fromSQLite(map);
    }
    return null;
  }

  @override
  Future<List<LessonProgressEntity>> getCourseProgress(String courseId) async {
    final maps = await _localDataSource.getCourseProgress(courseId);
    return maps.map((m) => LessonProgressMapper.fromSQLite(m)).toList();
  }

  @override
  Future<void> saveProgressLocally(LessonProgressEntity progress) async {
    // 1. Obter o progresso local anterior para aplicar a regra de resolução de conflitos
    final existing = await getProgress(progress.courseId, progress.lessonId);

    // Regra de conflito local: não regredir progresso
    var resolvedProgress = progress;
    if (existing != null) {
      final isCompleted = existing.completed || progress.completed;
      final maxSeconds = progress.watchedSeconds > existing.watchedSeconds
          ? progress.watchedSeconds
          : existing.watchedSeconds;
      final maxPercentage =
          progress.progressPercentage > existing.progressPercentage
          ? progress.progressPercentage
          : existing.progressPercentage;

      resolvedProgress = progress.copyWith(
        completed: isCompleted,
        watchedSeconds: maxSeconds,
        progressPercentage: maxPercentage,
        completedAt: isCompleted
            ? (progress.completedAt ?? existing.completedAt ?? DateTime.now())
            : null,
      );
    }

    // 2. Persistir localmente no SQLite
    final sqliteMap = LessonProgressMapper.toSQLite(resolvedProgress);
    await _localDataSource.saveProgress(sqliteMap);

    // 3. Enfileirar item de sincronização pendente
    final idempotencyKey =
        'sync_${resolvedProgress.courseId}_${resolvedProgress.lessonId}_${DateTime.now().millisecondsSinceEpoch}';
    final payload = LessonProgressMapper.toApi(resolvedProgress);
    payload['device_id'] = await _getInstallationId();
    payload['correlation_id'] = const Uuid().v4();

    await _localDataSource.enqueueSyncItem({
      'operation_type': 'UPDATE_PROGRESS',
      'entity_type': 'LESSON_PROGRESS',
      'entity_id': resolvedProgress.lessonId,
      'payload': jsonEncode(payload),
      'idempotency_key': idempotencyKey,
      'status': 'pending',
      'retry_count': 0,
      'next_retry_at': null,
      'last_error': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> syncProgressWithServer(
    LessonProgressEntity progress,
    String idempotencyKey,
  ) async {
    final payload = LessonProgressMapper.toApi(progress);
    payload['device_id'] = await _getInstallationId();
    payload['correlation_id'] = const Uuid().v4();
    payload['event_id'] = idempotencyKey;
    payload['idempotency_key'] = idempotencyKey;
    payload['occurred_at'] = DateTime.now().toUtc().toIso8601String();

    await _networkClient.patch(
      '/api/v1/offline/progress/${progress.lessonId}',
      data: payload,
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
  }

  @override
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    final maps = await _localDataSource.getPendingSyncItems();
    return maps.map((m) {
      return SyncQueueItem(
        id: m['id'] as int,
        operationType: m['operation_type'] as String,
        entityType: m['entity_type'] as String,
        entityId: m['entity_id'] as String,
        payload: jsonDecode(m['payload'] as String) as Map<String, dynamic>,
        idempotencyKey: m['idempotency_key'] as String,
        status: m['status'] as String,
        retryCount: m['retry_count'] as int,
        nextRetryAt: m['next_retry_at'] != null
            ? DateTime.tryParse(m['next_retry_at'] as String)
            : null,
        lastError: m['last_error'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> processSyncQueue() async {
    final items = await getPendingSyncItems();
    if (items.isEmpty) return;

    final readyItems = items
        .where(
          (item) =>
              item.nextRetryAt == null ||
              !item.nextRetryAt!.isAfter(DateTime.now()),
        )
        .take(100)
        .toList();
    if (readyItems.isEmpty) return;

    try {
      final response = await _networkClient.post<Map<String, dynamic>>(
        '/api/v1/offline/sync',
        data: {
          'events': readyItems.map((item) {
            final completed = item.payload['completed'] as bool? ?? false;
            return {
              'id': item.idempotencyKey,
              'action': completed
                  ? 'LESSON_COMPLETED'
                  : 'UPDATE_LESSON_PROGRESS',
              'payload': item.payload,
              'created_at': item.createdAt.millisecondsSinceEpoch ~/ 1000,
              'idempotency_key': item.idempotencyKey,
            };
          }).toList(),
        },
      );
      final resultList = response.data?['results'] as List<dynamic>? ?? [];
      final resultById = {
        for (final result in resultList.whereType<Map<String, dynamic>>())
          result['id'] as String: result,
      };

      for (final item in readyItems) {
        final result = resultById[item.idempotencyKey];
        if (result?['status'] == 'COMPLETED') {
          if (item.id != null) {
            await _localDataSource.deleteSyncItem(item.id!);
          }
          final payload = item.payload;
          final localProgress = await getProgress(
            payload['course_id'] as String,
            payload['lesson_id'] as String,
          );
          if (localProgress != null) {
            await _localDataSource.saveProgress(
              LessonProgressMapper.toSQLite(
                localProgress.copyWith(lastSyncedAt: DateTime.now()),
              ),
            );
          }
        } else {
          await _markItemForRetry(item, 'Server rejected progress event');
        }
      }
    } catch (error) {
      for (final item in readyItems) {
        await _markItemForRetry(item, error.toString());
      }
    }
  }

  Future<void> _markItemForRetry(SyncQueueItem item, String error) async {
    final newRetryCount = item.retryCount + 1;
    final cappedRetryCount = newRetryCount > 10 ? 10 : newRetryCount;
    final nextRetry = DateTime.now().add(
      Duration(seconds: 1 << cappedRetryCount),
    );
    if (item.id != null) {
      await _localDataSource.updateSyncItemStatus(
        item.id!,
        status: newRetryCount > 5 ? 'failed' : 'pending',
        retryCount: newRetryCount,
        nextRetryAt: nextRetry.toIso8601String(),
        lastError: error,
      );
    }
  }

  @override
  Future<List<LessonProgressEntity>> fetchAllRemoteProgress() async {
    final response = await _networkClient.get('/api/v1/offline/progress');
    final list = response.data as List? ?? [];
    return list.map((json) {
      return LessonProgressEntity(
        courseId: json['course_id'] as String,
        lessonId: json['lesson_id'] as String,
        watchedSeconds: json['watched_seconds'] as int,
        progressPercentage: (json['progress_percentage'] as num).toDouble(),
        completed: json['completed'] as bool,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );
    }).toList();
  }
}
