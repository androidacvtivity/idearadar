class IdeaEvaluation {
  const IdeaEvaluation({
    required this.problemScore,
    required this.marketScore,
    required this.demandScore,
    required this.competitionScore,
    required this.dataAccessScore,
    required this.technicalFeasibilityScore,
    required this.monetizationScore,
    required this.firstClientScore,
    this.rationale = '',
  }) : assert(problemScore >= 1 && problemScore <= 5),
       assert(marketScore >= 1 && marketScore <= 5),
       assert(demandScore >= 1 && demandScore <= 5),
       assert(competitionScore >= 1 && competitionScore <= 5),
       assert(dataAccessScore >= 1 && dataAccessScore <= 5),
       assert(
         technicalFeasibilityScore >= 1 &&
             technicalFeasibilityScore <= 5,
       ),
       assert(monetizationScore >= 1 && monetizationScore <= 5),
       assert(firstClientScore >= 1 && firstClientScore <= 5);

  final int problemScore;
  final int marketScore;
  final int demandScore;
  final int competitionScore;
  final int dataAccessScore;
  final int technicalFeasibilityScore;
  final int monetizationScore;
  final int firstClientScore;
  final String rationale;

  int get totalScore =>
      problemScore +
      marketScore +
      demandScore +
      competitionScore +
      dataAccessScore +
      technicalFeasibilityScore +
      monetizationScore +
      firstClientScore;
}
