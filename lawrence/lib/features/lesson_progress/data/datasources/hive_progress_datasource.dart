import 'package:hive/hive.dart';

import 'progress_local_datasource.dart';

class HiveProgressDataSource implements ProgressLocalDataSource {
  static const boxName = 'lesson_progress_web';
  static const _queueKey = 'sync_queue';
  static const _nextQueueIdKey = 'next_queue_id';

  Future<Box<dynamic>> get _box => Hive.openBox<dynamic>(boxName);

  String _progressKey(String courseId, String lessonId) =>
      'progress::$courseId::$lessonId';

  Map<String, dynamic> _map(dynamic value) =>
      Map<String, dynamic>.from(value as Map);

  @override
  Future<Map<String, dynamic>?> getProgress(
    String courseId,
    String lessonId,
  ) async {
    final value = (await _box).get(_progressKey(courseId, lessonId));
    return value is Map ? _map(value) : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseProgress(String courseId) async {
    final prefix = 'progress::$courseId::';
    final box = await _box;
    return box.keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .map(box.get)
        .whereType<Map>()
        .map(_map)
        .toList(growable: false);
  }

  @override
  Future<void> saveProgress(Map<String, dynamic> progress) async {
    await (await _box).put(
      _progressKey(
        progress['course_id'] as String,
        progress['lesson_id'] as String,
      ),
      Map<String, dynamic>.from(progress),
    );
  }

  @override
  Future<void> enqueueSyncItem(Map<String, dynamic> item) async {
    final box = await _box;
    final nextId = (box.get(_nextQueueIdKey) as int? ?? 0) + 1;
    final queue = _readQueue(box);
    queue.add({...item, 'id': nextId});
    await box.putAll({_queueKey: queue, _nextQueueIdKey: nextId});
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final queue = _readQueue(await _box)
        .where((item) => item['status'] == 'pending')
        .toList(growable: false);
    queue.sort(
      (left, right) => (left['created_at'] as String).compareTo(
        right['created_at'] as String,
      ),
    );
    return queue;
  }

  @override
  Future<void> updateSyncItemStatus(
    int id, {
    required String status,
    required int retryCount,
    String? nextRetryAt,
    String? lastError,
  }) async {
    final box = await _box;
    final queue = _readQueue(box);
    final index = queue.indexWhere((item) => item['id'] == id);
    if (index < 0) return;
    queue[index] = {
      ...queue[index],
      'status': status,
      'retry_count': retryCount,
      'next_retry_at': nextRetryAt,
      'last_error': lastError,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await box.put(_queueKey, queue);
  }

  @override
  Future<void> deleteSyncItem(int id) async {
    final box = await _box;
    final queue = _readQueue(box)..removeWhere((item) => item['id'] == id);
    await box.put(_queueKey, queue);
  }

  List<Map<String, dynamic>> _readQueue(Box<dynamic> box) {
    final value = box.get(_queueKey);
    if (value is! List) return <Map<String, dynamic>>[];
    return value.whereType<Map>().map(_map).toList();
  }
}
