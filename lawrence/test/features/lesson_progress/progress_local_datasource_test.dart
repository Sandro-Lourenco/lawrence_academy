import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lawrence/app/providers/learning_repositories.dart';
import 'package:lawrence/features/lesson_progress/data/datasources/hive_progress_datasource.dart';
import 'package:lawrence/features/lesson_progress/data/datasources/sqlite_progress_datasource.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'lawrence_progress_web_test_',
    );
    Hive.init(hiveDirectory.path);
  });

  setUp(() async {
    await Hive.deleteBoxFromDisk(HiveProgressDataSource.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveDirectory.existsSync()) {
      hiveDirectory.deleteSync(recursive: true);
    }
  });

  test('web factory never selects sqflite', () {
    expect(
      createProgressLocalDataSource(isWeb: true),
      isA<HiveProgressDataSource>(),
    );
    expect(
      createProgressLocalDataSource(isWeb: false),
      isA<SQLiteProgressDataSource>(),
    );
  });

  test('Hive adapter persists progress and pending sync events', () async {
    final dataSource = HiveProgressDataSource();
    final progress = <String, dynamic>{
      'course_id': 'course-1',
      'lesson_id': 'lesson-1',
      'watched_seconds': 45,
      'progress_percentage': 30.0,
      'completed': 0,
      'completed_at': null,
      'last_synced_at': null,
    };
    final now = DateTime.now().toIso8601String();

    await dataSource.saveProgress(progress);
    await dataSource.enqueueSyncItem({
      'operation_type': 'UPDATE_PROGRESS',
      'entity_type': 'LESSON_PROGRESS',
      'entity_id': 'lesson-1',
      'payload': '{}',
      'idempotency_key': 'event-1',
      'status': 'pending',
      'retry_count': 0,
      'next_retry_at': null,
      'last_error': null,
      'created_at': now,
      'updated_at': now,
    });

    expect(
      await dataSource.getProgress('course-1', 'lesson-1'),
      containsPair('watched_seconds', 45),
    );
    expect(await dataSource.getCourseProgress('course-1'), hasLength(1));

    final pending = await dataSource.getPendingSyncItems();
    expect(pending, hasLength(1));
    expect(pending.single['idempotency_key'], 'event-1');

    await dataSource.deleteSyncItem(pending.single['id'] as int);
    expect(await dataSource.getPendingSyncItems(), isEmpty);
  });
}
