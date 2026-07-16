import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';

class InMemoryIdeaRepository implements IdeaRepository {
  InMemoryIdeaRepository({
    List<Idea> seedIdeas = const [],
    List<IdeaNote> seedNotes = const [],
  }) : _ideas = List<Idea>.from(seedIdeas),
       _notes = List<IdeaNote>.from(seedNotes);

  final List<Idea> _ideas;
  final List<IdeaNote> _notes;

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
}
