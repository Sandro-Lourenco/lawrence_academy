import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static void setMockDatabase(Database db) {
    _database = db;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lawrence_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela de Fila de Sincronização (Eventos de Domínio)
        await db.execute('''
          CREATE TABLE sync_queue(
            id TEXT PRIMARY KEY,
            action TEXT NOT NULL,
            payload TEXT NOT NULL,
            status TEXT,
            retry_count INTEGER DEFAULT 0,
            next_retry_at INTEGER,
            created_at INTEGER
          )
        ''');

        // Tabela de Cursos Offline
        await db.execute('''
          CREATE TABLE offline_courses(
            id TEXT PRIMARY KEY,
            course_id TEXT,
            student_id TEXT,
            downloaded_at INTEGER,
            expires_at INTEGER
          )
        ''');

        // Tabela de Aulas Offline
        await db.execute('''
          CREATE TABLE offline_lessons(
            id TEXT PRIMARY KEY,
            lesson_id TEXT,
            course_id TEXT,
            progress INTEGER,
            file_path TEXT
          )
        ''');

        // Mantendo a tabela de progresso local (cache relacional das aulas online/offline)
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migrations futuras irão aqui
      },
    );
  }
}
