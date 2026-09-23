enum QuestionIdeaRelationType {
  questionCreatedIdea,
  ideaCreatedQuestion,
  related,
}

class QuestionIdeaLink {
  const QuestionIdeaLink({
    required this.questionId,
    required this.ideaId,
    required this.relationType,
    required this.createdAt,
  });

  final String questionId;
  final String ideaId;
  final QuestionIdeaRelationType relationType;
  final DateTime createdAt;
}
