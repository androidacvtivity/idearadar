import 'package:idearadar/features/ideas/domain/idea.dart';

sealed class IdeaDetailsResult {
  const IdeaDetailsResult();
}

final class IdeaUpdatedResult extends IdeaDetailsResult {
  const IdeaUpdatedResult(this.idea);

  final Idea idea;
}

final class IdeaDeletedResult extends IdeaDetailsResult {
  const IdeaDeletedResult(this.ideaId);

  final String ideaId;
}
