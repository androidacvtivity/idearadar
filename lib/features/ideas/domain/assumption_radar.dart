import 'idea_assumption.dart';

class AssumptionRadarResult {
  const AssumptionRadarResult({
    required this.overallConfidence,
    required this.criticalAssumptions,
    required this.weakestSignal,
    required this.nextExperiment,
  });

  final int overallConfidence;
  final int criticalAssumptions;
  final IdeaAssumption? weakestSignal;
  final String? nextExperiment;

  bool get hasUnprovenCriticalAssumptions =>
      weakestSignal != null && weakestSignal!.confidencePercent < 75;
}

class AssumptionRadar {
  const AssumptionRadar._();

  static AssumptionRadarResult analyze(List<IdeaAssumption> assumptions) {
    final critical = assumptions.where((item) => item.isCritical).toList();

    if (critical.isEmpty) {
      return const AssumptionRadarResult(
        overallConfidence: 0,
        criticalAssumptions: 0,
        weakestSignal: null,
        nextExperiment: null,
      );
    }

    critical.sort((a, b) {
      final byConfidence =
          a.confidencePercent.compareTo(b.confidencePercent);
      if (byConfidence != 0) {
        return byConfidence;
      }
      return a.evidenceCount.compareTo(b.evidenceCount);
    });

    final total = critical.fold<int>(
      0,
      (sum, item) => sum + item.confidencePercent,
    );
    final weakest = critical.first;

    return AssumptionRadarResult(
      overallConfidence: (total / critical.length).round(),
      criticalAssumptions: critical.length,
      weakestSignal: weakest,
      nextExperiment: _nextExperimentFor(weakest),
    );
  }

  static String _nextExperimentFor(IdeaAssumption assumption) {
    final customExperiment = assumption.nextExperiment?.trim();
    if (customExperiment != null && customExperiment.isNotEmpty) {
      return customExperiment;
    }

    switch (assumption.type) {
      case IdeaAssumptionType.problem:
        return 'Interview 5 target users and ask when this problem last occurred.';
      case IdeaAssumptionType.customer:
        return 'Describe one narrow customer segment and find 5 real examples.';
      case IdeaAssumptionType.willingnessToPay:
        return 'Ask 5 target customers for a concrete price they would pay.';
      case IdeaAssumptionType.acquisition:
        return 'Choose one acquisition channel and try to reach 10 target users.';
      case IdeaAssumptionType.feasibility:
        return 'Build or estimate the smallest risky part of the solution.';
      case IdeaAssumptionType.differentiation:
        return 'Compare the idea with 5 alternatives customers can use today.';
      case IdeaAssumptionType.founderFit:
        return 'List the skills, access, and advantages you already have for this idea.';
      case IdeaAssumptionType.custom:
        return 'Define one small experiment that could disprove this assumption.';
    }
  }
}
