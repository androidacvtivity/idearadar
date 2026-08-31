import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/domain/assumption_radar.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';

void main() {
  group('AssumptionRadar', () {
    test('finds the weakest critical assumption', () {
      const assumptions = [
        IdeaAssumption(
          id: 1,
          ideaId: 10,
          title: 'People experience the problem often',
          type: IdeaAssumptionType.problem,
          confidence: AssumptionConfidence.supported,
          evidenceCount: 4,
        ),
        IdeaAssumption(
          id: 2,
          ideaId: 10,
          title: 'Customers will pay',
          type: IdeaAssumptionType.willingnessToPay,
          confidence: AssumptionConfidence.weak,
        ),
        IdeaAssumption(
          id: 3,
          ideaId: 10,
          title: 'The MVP is feasible',
          type: IdeaAssumptionType.feasibility,
          confidence: AssumptionConfidence.strong,
          evidenceCount: 2,
        ),
      ];

      final result = AssumptionRadar.analyze(assumptions);

      expect(result.overallConfidence, 67);
      expect(result.criticalAssumptions, 3);
      expect(result.weakestSignal?.id, 2);
      expect(result.hasUnprovenCriticalAssumptions, isTrue);
      expect(result.nextExperiment, contains('concrete price'));
    });

    test('uses evidence count to break confidence ties', () {
      const assumptions = [
        IdeaAssumption(
          id: 1,
          ideaId: 10,
          title: 'Acquisition works',
          type: IdeaAssumptionType.acquisition,
          confidence: AssumptionConfidence.uncertain,
          evidenceCount: 3,
        ),
        IdeaAssumption(
          id: 2,
          ideaId: 10,
          title: 'Customers will pay',
          type: IdeaAssumptionType.willingnessToPay,
          confidence: AssumptionConfidence.uncertain,
          evidenceCount: 0,
        ),
      ];

      final result = AssumptionRadar.analyze(assumptions);

      expect(result.weakestSignal?.id, 2);
    });

    test('ignores non-critical assumptions in radar confidence', () {
      const assumptions = [
        IdeaAssumption(
          id: 1,
          ideaId: 10,
          title: 'Core problem exists',
          type: IdeaAssumptionType.problem,
          confidence: AssumptionConfidence.strong,
        ),
        IdeaAssumption(
          id: 2,
          ideaId: 10,
          title: 'Optional branding assumption',
          type: IdeaAssumptionType.custom,
          confidence: AssumptionConfidence.untested,
          isCritical: false,
        ),
      ];

      final result = AssumptionRadar.analyze(assumptions);

      expect(result.overallConfidence, 100);
      expect(result.criticalAssumptions, 1);
      expect(result.weakestSignal?.id, 1);
      expect(result.hasUnprovenCriticalAssumptions, isFalse);
    });

    test('returns an empty result when there are no critical assumptions', () {
      final result = AssumptionRadar.analyze(const []);

      expect(result.overallConfidence, 0);
      expect(result.criticalAssumptions, 0);
      expect(result.weakestSignal, isNull);
      expect(result.nextExperiment, isNull);
    });
  });
}
