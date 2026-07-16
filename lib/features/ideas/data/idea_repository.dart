import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';
import 'package:idearadar/features/ideas/domain/idea_source.dart';

abstract interface class IdeaRepository {
  Future<void> initialize();

  Future<List<Idea>> getIdeas();

  Future<void> addIdea(Idea idea);

  Future<void> updateIdea(Idea idea);

  Future<void> deleteIdea(String ideaId);

  Future<List<IdeaNote>> getNotes(String ideaId);

  Future<void> addNote(IdeaNote note);

  Future<void> updateNote(IdeaNote note);

  Future<void> deleteNote(String noteId);

  Future<List<IdeaSource>> getSources(String ideaId);

  Future<void> addSource(IdeaSource source);

  Future<void> updateSource(IdeaSource source);

  Future<void> deleteSource(String sourceId);
}
