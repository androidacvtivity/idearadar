import 'package:idearadar/features/ideas/data/idea_database.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';
import 'package:idearadar/features/ideas/domain/idea_evaluation.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';
import 'package:idearadar/features/ideas/domain/idea_source.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';
import 'package:sqflite/sqflite.dart';

class SqliteIdeaRepository implements IdeaRepository {
  SqliteIdeaRepository(this._ideaDatabase);

  final IdeaDatabase _ideaDatabase;

  @override
  Future<void> initialize() {
    return _ideaDatabase.initialize();
  }

  @override
  Future<List<Idea>> getIdeas() async {
    final database = await _ideaDatabase.database;
    final records = await database.query(
      IdeaDatabase.ideasTable,
      orderBy: 'updated_at DESC',
    );

    return records.map(_ideaFromMap).toList(growable: false);
  }

  @override
  Future<void> addIdea(Idea idea) async {
    final database = await _ideaDatabase.database;
    await database.insert(
      IdeaDatabase.ideasTable,
      _ideaToMap(idea),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateIdea(Idea idea) async {
    final database = await _ideaDatabase.database;
    final updatedRows = await database.update(
      IdeaDatabase.ideasTable,
      _ideaToMap(idea),
      where: 'id = ?',
      whereArgs: [idea.id],
    );

    if (updatedRows != 1) {
      throw StateError('Idea not found: ${idea.id}');
    }
  }

  @override
  Future<void> deleteIdea(String ideaId) async {
    final database = await _ideaDatabase.database;
    final deletedRows = await database.delete(
      IdeaDatabase.ideasTable,
      where: 'id = ?',
      whereArgs: [ideaId],
    );

    if (deletedRows != 1) {
      throw StateError('Idea not found: $ideaId');
    }
  }

  @override
  Future<List<IdeaNote>> getNotes(String ideaId) async {
    final database = await _ideaDatabase.database;
    final records = await database.query(
      IdeaDatabase.notesTable,
      where: 'idea_id = ?',
      whereArgs: [ideaId],
      orderBy: 'updated_at DESC',
    );
    return records.map(_noteFromMap).toList(growable: false);
  }

  @override
  Future<void> addNote(IdeaNote note) async {
    final database = await _ideaDatabase.database;
    await database.insert(IdeaDatabase.notesTable, _noteToMap(note));
  }

  @override
  Future<void> updateNote(IdeaNote note) async {
    final database = await _ideaDatabase.database;
    final updatedRows = await database.update(
      IdeaDatabase.notesTable,
      _noteToMap(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updatedRows != 1) {
      throw StateError('Note not found: ${note.id}');
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final database = await _ideaDatabase.database;
    final deletedRows = await database.delete(
      IdeaDatabase.notesTable,
      where: 'id = ?',
      whereArgs: [noteId],
    );
    if (deletedRows != 1) {
      throw StateError('Note not found: $noteId');
    }
  }

  @override
  Future<List<IdeaSource>> getSources(String ideaId) async {
    final database = await _ideaDatabase.database;
    final records = await database.query(
      IdeaDatabase.sourcesTable,
      where: 'idea_id = ?',
      whereArgs: [ideaId],
      orderBy: 'accessed_at DESC',
    );
    return records.map(_sourceFromMap).toList(growable: false);
  }

  @override
  Future<void> addSource(IdeaSource source) async {
    final database = await _ideaDatabase.database;
    await database.insert(IdeaDatabase.sourcesTable, _sourceToMap(source));
  }

  @override
  Future<void> updateSource(IdeaSource source) async {
    final database = await _ideaDatabase.database;
    final updatedRows = await database.update(
      IdeaDatabase.sourcesTable,
      _sourceToMap(source),
      where: 'id = ?',
      whereArgs: [source.id],
    );
    if (updatedRows != 1) {
      throw StateError('Source not found: ${source.id}');
    }
  }

  @override
  Future<void> deleteSource(String sourceId) async {
    final database = await _ideaDatabase.database;
    final deletedRows = await database.delete(
      IdeaDatabase.sourcesTable,
      where: 'id = ?',
      whereArgs: [sourceId],
    );
    if (deletedRows != 1) {
      throw StateError('Source not found: $sourceId');
    }
  }

  @override
  Future<List<IdeaAssumption>> getAssumptions(String ideaId) async {
    final database = await _ideaDatabase.database;
    final records = await database.query(
      IdeaDatabase.assumptionsTable,
      where: 'idea_id = ?',
      whereArgs: [ideaId],
      orderBy: 'is_critical DESC, rowid ASC',
    );
    return records.map(_assumptionFromMap).toList(growable: false);
  }

  @override
  Future<void> addAssumption(IdeaAssumption assumption) async {
    final database = await _ideaDatabase.database;
    await database.insert(
      IdeaDatabase.assumptionsTable,
      _assumptionToMap(assumption),
    );
  }

  @override
  Future<void> updateAssumption(IdeaAssumption assumption) async {
    final database = await _ideaDatabase.database;
    final updatedRows = await database.update(
      IdeaDatabase.assumptionsTable,
      _assumptionToMap(assumption),
      where: 'id = ?',
      whereArgs: [assumption.id],
    );
    if (updatedRows != 1) {
      throw StateError('Assumption not found: ${assumption.id}');
    }
  }

  @override
  Future<void> deleteAssumption(String assumptionId) async {
    final database = await _ideaDatabase.database;
    final deletedRows = await database.delete(
      IdeaDatabase.assumptionsTable,
      where: 'id = ?',
      whereArgs: [assumptionId],
    );
    if (deletedRows != 1) {
      throw StateError('Assumption not found: $assumptionId');
    }
  }

  Map<String, Object?> _assumptionToMap(IdeaAssumption assumption) {
    return {
      'id': assumption.id,
      'idea_id': assumption.ideaId,
      'title': assumption.title,
      'assumption_type': assumption.type.name,
      'confidence': assumption.confidence.name,
      'evidence_count': assumption.evidenceCount,
      'next_experiment': assumption.nextExperiment,
      'is_critical': assumption.isCritical ? 1 : 0,
    };
  }

  IdeaAssumption _assumptionFromMap(Map<String, Object?> map) {
    return IdeaAssumption(
      id: map['id']! as String,
      ideaId: map['idea_id']! as String,
      title: map['title']! as String,
      type: IdeaAssumptionType.values.firstWhere(
        (type) => type.name == map['assumption_type'],
        orElse: () => IdeaAssumptionType.custom,
      ),
      confidence: AssumptionConfidence.values.firstWhere(
        (confidence) => confidence.name == map['confidence'],
        orElse: () => AssumptionConfidence.untested,
      ),
      evidenceCount: map['evidence_count']! as int,
      nextExperiment: map['next_experiment'] as String?,
      isCritical: (map['is_critical']! as int) == 1,
    );
  }

  Map<String, Object?> _sourceToMap(IdeaSource source) {
    return {
      'id': source.id,
      'idea_id': source.ideaId,
      'title': source.title,
      'url': source.url,
      'source_type': source.sourceType.name,
      'note': source.note,
      'accessed_at': source.accessedAt.toIso8601String(),
      'created_at': source.createdAt.toIso8601String(),
    };
  }

  IdeaSource _sourceFromMap(Map<String, Object?> map) {
    return IdeaSource(
      id: map['id']! as String,
      ideaId: map['idea_id']! as String,
      title: map['title']! as String,
      url: map['url']! as String,
      sourceType: IdeaSourceType.values.firstWhere(
        (type) => type.name == map['source_type'],
        orElse: () => IdeaSourceType.other,
      ),
      note: map['note']! as String,
      accessedAt: DateTime.parse(map['accessed_at']! as String),
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }

  Map<String, Object?> _noteToMap(IdeaNote note) {
    return {
      'id': note.id,
      'idea_id': note.ideaId,
      'content': note.content,
      'created_at': note.createdAt.toIso8601String(),
      'updated_at': note.updatedAt.toIso8601String(),
    };
  }

  IdeaNote _noteFromMap(Map<String, Object?> map) {
    return IdeaNote(
      id: map['id']! as String,
      ideaId: map['idea_id']! as String,
      content: map['content']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  Map<String, Object?> _ideaToMap(Idea idea) {
    final evaluation = idea.evaluation;

    return {
      'id': idea.id,
      'title': idea.title,
      'summary': idea.summary,
      'problem': idea.problem,
      'solution': idea.solution,
      'domain': idea.domain,
      'target_users': idea.targetUsers,
      'paying_customer': idea.payingCustomer,
      'status': idea.status.name,
      'problem_score': evaluation?.problemScore,
      'market_score': evaluation?.marketScore,
      'demand_score': evaluation?.demandScore,
      'competition_score': evaluation?.competitionScore,
      'data_access_score': evaluation?.dataAccessScore,
      'technical_feasibility_score': evaluation?.technicalFeasibilityScore,
      'monetization_score': evaluation?.monetizationScore,
      'first_client_score': evaluation?.firstClientScore,
      'evaluation_rationale': evaluation?.rationale,
      'created_at': idea.createdAt.toIso8601String(),
      'updated_at': idea.updatedAt.toIso8601String(),
      'next_review_at': idea.nextReviewAt?.toIso8601String(),
      'archived_at': idea.archivedAt?.toIso8601String(),
    };
  }

  Idea _ideaFromMap(Map<String, Object?> map) {
    return Idea(
      id: map['id']! as String,
      title: map['title']! as String,
      summary: map['summary']! as String,
      problem: map['problem']! as String,
      solution: map['solution']! as String,
      domain: map['domain']! as String,
      targetUsers: map['target_users']! as String,
      payingCustomer: map['paying_customer']! as String,
      status: _statusFromName(map['status']! as String),
      evaluation: _evaluationFromMap(map),
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      nextReviewAt: _optionalDate(map['next_review_at']),
      archivedAt: _optionalDate(map['archived_at']),
    );
  }

  IdeaEvaluation? _evaluationFromMap(Map<String, Object?> map) {
    final problemScore = map['problem_score'] as int?;
    if (problemScore == null) {
      return null;
    }

    return IdeaEvaluation(
      problemScore: problemScore,
      marketScore: map['market_score']! as int,
      demandScore: map['demand_score']! as int,
      competitionScore: map['competition_score']! as int,
      dataAccessScore: map['data_access_score']! as int,
      technicalFeasibilityScore: map['technical_feasibility_score']! as int,
      monetizationScore: map['monetization_score']! as int,
      firstClientScore: map['first_client_score']! as int,
      rationale: map['evaluation_rationale'] as String? ?? '',
    );
  }

  IdeaStatus _statusFromName(String name) {
    return IdeaStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => IdeaStatus.newIdea,
    );
  }

  DateTime? _optionalDate(Object? value) {
    return value == null ? null : DateTime.parse(value as String);
  }
}
