import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';
import 'package:idearadar/features/ideas/domain/idea_source.dart';

class InMemoryIdeaRepository implements IdeaRepository {
  InMemoryIdeaRepository({
    List<Idea> seedIdeas = const [],
    List<IdeaNote> seedNotes = const [],
    List<IdeaSource> seedSources = const [],
    List<IdeaAssumption> seedAssumptions = const [],
  }) : _ideas = List<Idea>.from(seedIdeas),
       _notes = List<IdeaNote>.from(seedNotes),
       _sources = List<IdeaSource>.from(seedSources),
       _assumptions = List<IdeaAssumption>.from(seedAssumptions);

  final List<Idea> _ideas;
  final List<IdeaNote> _notes;
  final List<IdeaSource> _sources;
  final List<IdeaAssumption> _assumptions;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<Idea>> getIdeas() async {
    return List<Idea>.unmodifiable(_ideas);
  }

  @override
  Future<void> addIdea(Idea idea) async {
    _ideas.insert(0, idea);
  }

  @override
  Future<void> updateIdea(Idea idea) async {
    final index = _ideas.indexWhere((current) => current.id == idea.id);
    if (index == -1) {
      throw StateError('Idea not found: ${idea.id}');
    }

    _ideas[index] = idea;
  }

  @override
  Future<void> deleteIdea(String ideaId) async {
    final removedIdeas = _ideas.where((idea) => idea.id == ideaId).length;
    if (removedIdeas != 1) {
      throw StateError('Idea not found: $ideaId');
    }

    _ideas.removeWhere((idea) => idea.id == ideaId);
    _notes.removeWhere((note) => note.ideaId == ideaId);
    _sources.removeWhere((source) => source.ideaId == ideaId);
    _assumptions.removeWhere((assumption) => assumption.ideaId == ideaId);
  }

  @override
  Future<List<IdeaNote>> getNotes(String ideaId) async {
    final notes = _notes.where((note) => note.ideaId == ideaId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List<IdeaNote>.unmodifiable(notes);
  }

  @override
  Future<void> addNote(IdeaNote note) async {
    if (!_ideas.any((idea) => idea.id == note.ideaId)) {
      throw StateError('Idea not found: ${note.ideaId}');
    }
    _notes.insert(0, note);
  }

  @override
  Future<void> updateNote(IdeaNote note) async {
    final index = _notes.indexWhere((current) => current.id == note.id);
    if (index == -1) {
      throw StateError('Note not found: ${note.id}');
    }
    _notes[index] = note;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final removedNotes = _notes.where((note) => note.id == noteId).length;
    if (removedNotes != 1) {
      throw StateError('Note not found: $noteId');
    }
    _notes.removeWhere((note) => note.id == noteId);
  }

  @override
  Future<List<IdeaSource>> getSources(String ideaId) async {
    final sources = _sources.where((source) => source.ideaId == ideaId).toList()
      ..sort((a, b) => b.accessedAt.compareTo(a.accessedAt));
    return List<IdeaSource>.unmodifiable(sources);
  }

  @override
  Future<void> addSource(IdeaSource source) async {
    if (!_ideas.any((idea) => idea.id == source.ideaId)) {
      throw StateError('Idea not found: ${source.ideaId}');
    }
    _sources.insert(0, source);
  }

  @override
  Future<void> updateSource(IdeaSource source) async {
    final index = _sources.indexWhere((current) => current.id == source.id);
    if (index == -1) {
      throw StateError('Source not found: ${source.id}');
    }
    _sources[index] = source;
  }

  @override
  Future<void> deleteSource(String sourceId) async {
    final removedSources = _sources
        .where((source) => source.id == sourceId)
        .length;
    if (removedSources != 1) {
      throw StateError('Source not found: $sourceId');
    }
    _sources.removeWhere((source) => source.id == sourceId);
  }

  @override
  Future<List<IdeaAssumption>> getAssumptions(String ideaId) async {
    final assumptions = _assumptions
        .where((assumption) => assumption.ideaId == ideaId)
        .toList();
    return List<IdeaAssumption>.unmodifiable(assumptions);
  }

  @override
  Future<void> addAssumption(IdeaAssumption assumption) async {
    if (!_ideas.any((idea) => idea.id == assumption.ideaId)) {
      throw StateError('Idea not found: ${assumption.ideaId}');
    }
    _assumptions.add(assumption);
  }

  @override
  Future<void> updateAssumption(IdeaAssumption assumption) async {
    final index = _assumptions.indexWhere(
      (current) => current.id == assumption.id,
    );
    if (index == -1) {
      throw StateError('Assumption not found: ${assumption.id}');
    }
    _assumptions[index] = assumption;
  }

  @override
  Future<void> deleteAssumption(String assumptionId) async {
    final removed = _assumptions
        .where((assumption) => assumption.id == assumptionId)
        .length;
    if (removed != 1) {
      throw StateError('Assumption not found: $assumptionId');
    }
    _assumptions.removeWhere((assumption) => assumption.id == assumptionId);
  }
}
