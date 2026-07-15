import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';

class InMemoryIdeaRepository implements IdeaRepository {
  InMemoryIdeaRepository({List<Idea> seedIdeas = const []})
    : _ideas = List<Idea>.from(seedIdeas);

  final List<Idea> _ideas;

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
}
