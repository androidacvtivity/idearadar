import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';
import 'package:idearadar/features/ideas/domain/starter_assumptions.dart';

void main() {
  test('creates a focused starter radar for an idea', () {
    final idea = Idea(
      id: 'idea-1',
      title: 'Local service marketplace',
      createdAt: DateTime(2026, 8, 31),
      updatedAt: DateTime(2026, 8, 31),
    );

    final assumptions = buildStarterAssumptions(idea);

    expect(assumptions, hasLength(6));
    expect(assumptions.every((item) => item.ideaId == idea.id), isTrue);
    expect(
      assumptions.map((item) => item.type),
      containsAll(<IdeaAssumptionType>[
        IdeaAssumptionType.problem,
        IdeaAssumptionType.customer,
        IdeaAssumptionType.willingnessToPay,
        IdeaAssumptionType.acquisition,
        IdeaAssumptionType.feasibility,
        IdeaAssumptionType.differentiation,
      ]),
    );
    expect(
      assumptions.every((item) => item.confidence == AssumptionConfidence.untested),
      isTrue,
    );
    expect(assumptions.every((item) => item.isCritical), isTrue);
  });
}
