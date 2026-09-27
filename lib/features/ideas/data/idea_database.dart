import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class IdeaDatabase {
  static const databaseName = 'idearadar.db';
  static const databaseVersion = 6;
  static const ideasTable = 'ideas';
  static const notesTable = 'idea_notes';
  static const sourcesTable = 'idea_sources';
  static const assumptionsTable = 'idea_assumptions';
  static const questionsTable = 'questions';
  static const questionIdeaLinksTable = 'question_idea_links';
  static const problemsTable = 'problems';
  static const problemIdeaLinksTable = 'problem_idea_links';
  static const problemQuestionLinksTable = 'problem_question_links';

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
        await _createQuestionsTable(database);
        await _createQuestionIdeaLinksTable(database);
        await _createProblemsTable(database);
        await _createProblemIdeaLinksTable(database);
        await _createProblemQuestionLinksTable(database);
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
        if (oldVersion < 5) {
          await _createQuestionsTable(database);
          await _createQuestionIdeaLinksTable(database);
        }
        if (oldVersion < 6) {
          await _createProblemsTable(database);
          await _createProblemIdeaLinksTable(database);
          await _createProblemQuestionLinksTable(database);
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

  static Future<void> _createQuestionsTable(Database database) {
    return database.execute('''
      CREATE TABLE $questionsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        details TEXT NOT NULL DEFAULT '',
        answer TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        answered_at TEXT
      )
    ''');
  }

  static Future<void> _createQuestionIdeaLinksTable(Database database) {
    return database.execute('''
      CREATE TABLE $questionIdeaLinksTable (
        question_id TEXT NOT NULL,
        idea_id TEXT NOT NULL,
        relation_type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (question_id, idea_id),
        FOREIGN KEY (question_id) REFERENCES $questionsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (idea_id) REFERENCES $ideasTable (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createProblemsTable(Database database) {
    return database.execute('''
      CREATE TABLE $problemsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        affected_users TEXT NOT NULL DEFAULT '',
        frequency TEXT NOT NULL DEFAULT '',
        severity TEXT NOT NULL DEFAULT '',
        current_workaround TEXT NOT NULL DEFAULT '',
        evidence TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createProblemIdeaLinksTable(Database database) {
    return database.execute('''
      CREATE TABLE $problemIdeaLinksTable (
        problem_id TEXT NOT NULL,
        idea_id TEXT NOT NULL,
        relation_type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (problem_id, idea_id),
        FOREIGN KEY (problem_id) REFERENCES $problemsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (idea_id) REFERENCES $ideasTable (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _createProblemQuestionLinksTable(Database database) {
    return database.execute('''
      CREATE TABLE $problemQuestionLinksTable (
        problem_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        relation_type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (problem_id, question_id),
        FOREIGN KEY (problem_id) REFERENCES $problemsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES $questionsTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<Database> get database async {
    await initialize();
    return _database!;
  }
}
