import 'package:idearadar/features/ideas/domain/idea.dart';

abstract interface class IdeaRepository {
  Future<void> initialize();

  Future<List<Idea>> getIdeas();

  Future<void> addIdea(Idea idea);
}
