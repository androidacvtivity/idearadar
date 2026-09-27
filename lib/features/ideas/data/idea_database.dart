import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class IdeaDatabase {
  static const databaseName = 'idearadar.db';
  static const databaseVersion = 7;
  static const ideasTable = 'ideas';
  static const notesTable = 'idea_notes';
  static const sourcesTable = 'idea_sources';
  static const assumptionsTable = 'idea_assumptions';
  static const questionsTable = 'questions';
  static const questionIdeaLinksTable = 'question_idea_links';
  static const problemsTable = 'problems';
  static const problemIdeaLinksTable = 'problem_idea_links';
  static const problemQuestionLinksTable = 'problem_question_links';
  static const appMetadataTable = 'app_metadata';

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
        await _createAppMetadataTable(database);
        await _seedDemoData(database);
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
        if (oldVersion < 7) {
          await _createAppMetadataTable(database);
          await _seedDemoData(database);
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

  static Future<void> _createAppMetadataTable(Database database) {
    return database.execute('''
      CREATE TABLE IF NOT EXISTS $appMetadataTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _seedDemoData(Database database) async {
    const seedKey = 'demo_seed_v1';
    final existing = await database.query(
      appMetadataTable,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [seedKey],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return;
    }

    final now = DateTime(2026, 9, 27, 12).toIso8601String();

    const roProblemId = 'demo-problem-ro';
    const roQuestionId = 'demo-question-ro';
    const roIdeaId = 'demo-idea-ro';

    const enProblemId = 'demo-problem-en';
    const enQuestionId = 'demo-question-en';
    const enIdeaId = 'demo-idea-en';

    final batch = database.batch();

    batch.insert(problemsTable, {
      'id': roProblemId,
      'title': 'Oamenii ocupați uită sarcini mici, dar importante',
      'description':
          'Sarcinile sunt notate în locuri diferite — mesaje, hârtie și aplicații de notițe — iar uneori sunt uitate.',
      'affected_users':
          'Persoane ocupate, părinți, angajați și persoane care gestionează multe activități zilnice.',
      'frequency': 'Frecvent, pe parcursul săptămânii.',
      'severity':
          'Poate duce la întârzieri, stres și activități importante ratate.',
      'current_workaround':
          'Liste pe hârtie, aplicații de notițe, alarme și mesaje trimise către sine.',
      'evidence':
          'Exemplu demonstrativ: observă problema și adaugă dovezi reale înainte de a construi soluția.',
      'status': 'observed',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert(questionsTable, {
      'id': roQuestionId,
      'title':
          'Care este cel mai simplu mod de a le reaminti oamenilor sarcinile importante fără să-i deranjeze?',
      'details':
          'Caută să înțelegi când, unde și prin ce tip de notificare ar fi util un reminder.',
      'answer': '',
      'status': 'open',
      'created_at': now,
      'updated_at': now,
      'answered_at': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert(ideasTable, {
      'id': roIdeaId,
      'title': 'Reminder simplu pentru sarcinile importante',
      'summary':
          'O aplicație care afișează câteva sarcini importante la momentele potrivite ale zilei.',
      'problem': 'Oamenii ocupați uită sarcini mici, dar importante.',
      'solution':
          'Un reminder simplu și discret, concentrat doar pe sarcinile importante.',
      'domain': 'Productivitate',
      'target_users': 'Persoane ocupate, părinți și angajați.',
      'paying_customer': 'Utilizatorul individual.',
      'status': 'newIdea',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert(problemsTable, {
      'id': enProblemId,
      'title': 'Useful information gets saved without context',
      'description':
          'Interesting articles, products, ideas, and resources are scattered across browsers, messages, screenshots, and notes.',
      'affected_users':
          'Students, professionals, researchers, entrepreneurs, and curious internet users.',
      'frequency': 'Several times a week for active internet users.',
      'severity':
          'Useful information is difficult to rediscover and often loses its original meaning.',
      'current_workaround':
          'Browser bookmarks, screenshots, note-taking apps, and sending links to yourself.',
      'evidence':
          'Demo example: validate the problem with real observations before building a solution.',
      'status': 'observed',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert(questionsTable, {
      'id': enQuestionId,
      'title':
          'How could useful information be captured together with the reason it was saved?',
      'details':
          'Explore what minimum context would make a saved resource useful again later.',
      'answer': '',
      'status': 'open',
      'created_at': now,
      'updated_at': now,
      'answered_at': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    batch.insert(ideasTable, {
      'id': enIdeaId,
      'title': 'Save links with a short reason',
      'summary':
          'A lightweight app that saves a link together with a short note explaining why it matters.',
      'problem': 'Useful information gets saved without context.',
      'solution':
          'Save each resource together with a short reason, tag, and optional next action.',
      'domain': 'Knowledge management',
      'target_users':
          'Students, professionals, researchers, and entrepreneurs.',
      'paying_customer': 'The individual user.',
      'status': 'newIdea',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    for (final values in [
      {
        'problem_id': roProblemId,
        'question_id': roQuestionId,
        'relation_type': 'problemCreatedQuestion',
        'created_at': now,
      },
      {
        'problem_id': enProblemId,
        'question_id': enQuestionId,
        'relation_type': 'problemCreatedQuestion',
        'created_at': now,
      },
    ]) {
      batch.insert(
        problemQuestionLinksTable,
        values,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final values in [
      {
        'problem_id': roProblemId,
        'idea_id': roIdeaId,
        'relation_type': 'problemCreatedIdea',
        'created_at': now,
      },
      {
        'problem_id': enProblemId,
        'idea_id': enIdeaId,
        'relation_type': 'problemCreatedIdea',
        'created_at': now,
      },
    ]) {
      batch.insert(
        problemIdeaLinksTable,
        values,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final values in [
      {
        'question_id': roQuestionId,
        'idea_id': roIdeaId,
        'relation_type': 'questionCreatedIdea',
        'created_at': now,
      },
      {
        'question_id': enQuestionId,
        'idea_id': enIdeaId,
        'relation_type': 'questionCreatedIdea',
        'created_at': now,
      },
    ]) {
      batch.insert(
        questionIdeaLinksTable,
        values,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    batch.insert(appMetadataTable, {
      'key': seedKey,
      'value': '1',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await batch.commit(noResult: true);
  }

  Future<Database> get database async {
    await initialize();
    return _database!;
  }
}
