import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class IdeaDatabase {
  static const databaseName = 'idearadar.db';
  static const databaseVersion = 4;
  static const ideasTable = 'ideas';
  static const notesTable = 'idea_notes';
  static const sourcesTable = 'idea_sources';
  static const assumptionsTable = 'idea_assumptions';

  Database? _database;

  Future<void> initialize() async {
    if (_database != null) {
      return;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, databaseName);

    _database = await openDatabase(
      databasePath,
      version: databaseVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await _createIdeasTable(database);
        await _createNotesTable(database);
        await _createSourcesTable(database);
        await _createAssumptionsTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createNotesTable(database);
        }
        if (oldVersion < 3) {
          await _createSourcesTable(database);
        }
        if (oldVersion < 4) {
          await _createAssumptionsTable(database);
        }
      },
    );
  }

  static Future<void> _createIdeasTable(Database database) {
    return database.execute('''
      CREATE TABLE $ideasTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        summary TEXT NOT NULL DEFAULT '',
        problem TEXT NOT NULL DEFAULT '',
        solution TEXT NOT NULL DEFAULT '',
        domain TEXT NOT NULL DEFAULT '',
        target_users TEXT NOT NULL DEFAULT '',
        paying_customer TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL,
        problem_score INTEGER,
        market_score INTEGER,
        demand_score INTEGER,
        competition_score INTEGER,
        data_access_score INTEGER,
        technical_feasibility_score INTEGER,
        monetization_score INTEGER,
        first_client_score INTEGER,
        evaluation_rationale TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        next_review_at TEXT,
        archived_at TEXT
      )
    ''');
  }

  static Future<void> _createNotesTable(Database database) {
    return database.execute('''
      CREATE TABLE $notesTable (
        id TEXT PRIMARY KEY,
        idea_id TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (idea_id) REFERENCES $ideasTable (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createSourcesTable(Database database) {
    return database.execute('''
      CREATE TABLE $sourcesTable (
        id TEXT PRIMARY KEY,
        idea_id TEXT NOT NULL,
        title TEXT NOT NULL,
        url TEXT NOT NULL DEFAULT '',
        source_type TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        accessed_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (idea_id) REFERENCES $ideasTable (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createAssumptionsTable(Database database) {
    return database.execute('''
      CREATE TABLE $assumptionsTable (
        id TEXT PRIMARY KEY,
        idea_id TEXT NOT NULL,
        title TEXT NOT NULL,
        assumption_type TEXT NOT NULL,
        confidence TEXT NOT NULL,
        evidence_count INTEGER NOT NULL DEFAULT 0,
        next_experiment TEXT,
        is_critical INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (idea_id) REFERENCES $ideasTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<Database> get database async {
    await initialize();
    return _database!;
  }
}
