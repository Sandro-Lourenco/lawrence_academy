import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteProgressDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Permite injetar uma instância mock/memória nos testes
  void setMockDatabase(Database db) {
    _database = db;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lawrence_progress.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela de Progresso das Lições
        await db.execute('''
          CREATE TABLE lesson_progress (
            course_id TEXT NOT NULL,
            lesson_id TEXT NOT NULL,
            watched_seconds INTEGER NOT NULL,
            progress_percentage REAL NOT NULL,
            completed INTEGER NOT NULL,
            completed_at TEXT,
            last_synced_at TEXT,
            PRIMARY KEY (course_id, lesson_id)
          )
        ''');

        // Tabela de Fila de Sincronização
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operation_type TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            payload TEXT NOT NULL,
            idempotency_key TEXT NOT NULL,
            status TEXT NOT NULL,
            retry_count INTEGER NOT NULL,
            next_retry_at TEXT,
            last_error TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- Operações de Progresso ---

  Future<Map<String, dynamic>?> getProgress(
    String courseId,
    String lessonId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'lesson_progress',
      where: 'course_id = ? AND lesson_id = ?',
      whereArgs: [courseId, lessonId],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getCourseProgress(String courseId) async {
    final db = await database;
    return await db.query(
      'lesson_progress',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
  }

  Future<void> saveProgress(Map<String, dynamic> progress) async {
    final db = await database;
    await db.insert(
      'lesson_progress',
      progress,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Operações de Fila de Sincronização ---

  Future<void> enqueueSyncItem(Map<String, dynamic> item) async {
    final db = await database;
    await db.insert(
      'sync_queue',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> updateSyncItemStatus(
    int id, {
    required String status,
    required int retryCount,
    String? nextRetryAt,
    String? lastError,
  }) async {
    final db = await database;
    await db.update(
      'sync_queue',
      {
        'status': status,
        'retry_count': retryCount,
        'next_retry_at': nextRetryAt,
        'last_error': lastError,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSyncItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}
