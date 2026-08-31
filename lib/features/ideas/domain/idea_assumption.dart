enum IdeaAssumptionType {
  problem,
  customer,
  willingnessToPay,
  acquisition,
  feasibility,
  differentiation,
  founderFit,
  custom,
}

enum AssumptionConfidence {
  untested,
  weak,
  uncertain,
  supported,
  strong,
}

class IdeaAssumption {
  const IdeaAssumption({
    required this.id,
    required this.ideaId,
    required this.title,
    required this.type,
    this.confidence = AssumptionConfidence.untested,
    this.evidenceCount = 0,
    this.nextExperiment,
    this.isCritical = true,
  }) : assert(id != ''),
       assert(ideaId != ''),
       assert(title != '');

  final String id;
  final String ideaId;
  final String title;
  final IdeaAssumptionType type;
  final AssumptionConfidence confidence;
  final int evidenceCount;
  final String? nextExperiment;
  final bool isCritical;

  int get confidencePercent {
    switch (confidence) {
      case AssumptionConfidence.untested:
        return 0;
      case AssumptionConfidence.weak:
        return 25;
      case AssumptionConfidence.uncertain:
        return 50;
      case AssumptionConfidence.supported:
        return 75;
      case AssumptionConfidence.strong:
        return 100;
    }
  }

  bool get needsAttention => isCritical && confidencePercent < 75;

  IdeaAssumption copyWith({
    String? id,
    String? ideaId,
    String? title,
    IdeaAssumptionType? type,
    AssumptionConfidence? confidence,
    int? evidenceCount,
    String? nextExperiment,
    bool? isCritical,
  }) {
    return IdeaAssumption(
      id: id ?? this.id,
      ideaId: ideaId ?? this.ideaId,
      title: title ?? this.title,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      nextExperiment: nextExperiment ?? this.nextExperiment,
      isCritical: isCritical ?? this.isCritical,
    );
  }
}
