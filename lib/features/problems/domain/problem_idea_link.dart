enum ProblemIdeaRelationType {
  problemCreatedIdea,
  ideaRevealedProblem,
  related,
}

class ProblemIdeaLink {
  const ProblemIdeaLink({
    required this.problemId,
    required this.ideaId,
    required this.relationType,
    required this.createdAt,
  });

  final String problemId;
  final String ideaId;
  final ProblemIdeaRelationType relationType;
  final DateTime createdAt;
}
