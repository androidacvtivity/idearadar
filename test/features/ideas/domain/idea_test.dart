import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_evaluation.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';

void main() {
  test('calculates an evaluation score out of 40', () {
    const evaluation = IdeaEvaluation(
      problemScore: 4,
      marketScore: 3,
      demandScore: 4,
      competitionScore: 3,
      dataAccessScore: 4,
      technicalFeasibilityScore: 5,
      monetizationScore: 3,
      firstClientScore: 4,
    );

    expect(evaluation.totalScore, 30);
  });

  test('creates and updates an idea without changing its identity', () {
    final createdAt = DateTime(2026, 7, 15);
    final idea = Idea(
      id: 'idea-001',
      title: 'IdeaRadar',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final updated = idea.copyWith(
      status: IdeaStatus.evaluating,
      updatedAt: DateTime(2026, 7, 16),
    );

    expect(updated.id, idea.id);
    expect(updated.title, 'IdeaRadar');
    expect(updated.status, IdeaStatus.evaluating);
    expect(updated.createdAt, createdAt);
  });
}
