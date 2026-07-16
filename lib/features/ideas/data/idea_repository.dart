import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';

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
}
