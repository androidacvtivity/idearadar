import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class IdeaDatabase {
  static const databaseName = 'idearadar.db';
  static const databaseVersion = 1;
  static const ideasTable = 'ideas';

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
      onCreate: (database, version) async {
        await database.execute('''
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
      },
    );
  }

  Future<Database> get database async {
    await initialize();
    return _database!;
  }
}
