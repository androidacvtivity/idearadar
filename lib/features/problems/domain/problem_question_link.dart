enum ProblemQuestionRelationType {
  problemCreatedQuestion,
  questionRevealedProblem,
  related,
}

class ProblemQuestionLink {
  const ProblemQuestionLink({
    required this.problemId,
    required this.questionId,
    required this.relationType,
    required this.createdAt,
  });

  final String problemId;
  final String questionId;
  final ProblemQuestionRelationType relationType;
  final DateTime createdAt;
}
