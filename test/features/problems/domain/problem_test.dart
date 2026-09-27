import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/problems/domain/problem.dart';

void main() {
  test('new problem is observed by default', () {
    final now = DateTime(2026, 9, 27);
    final problem = Problem(
      id: 'p1',
      title: 'Residents miss important building notices',
      createdAt: now,
      updatedAt: now,
    );

    expect(problem.status, ProblemStatus.observed);
    expect(problem.description, isEmpty);
    expect(problem.evidence, isEmpty);
  });

  test('copyWith updates research state without changing identity', () {
    final createdAt = DateTime(2026, 9, 27);
    final updatedAt = DateTime(2026, 9, 28);
    final problem = Problem(
      id: 'p1',
      title: 'Residents miss important building notices',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final researching = problem.copyWith(
      status: ProblemStatus.researching,
      evidence: 'Three administrators described the same issue.',
      updatedAt: updatedAt,
    );

    expect(researching.id, problem.id);
    expect(researching.createdAt, createdAt);
    expect(researching.updatedAt, updatedAt);
    expect(researching.status, ProblemStatus.researching);
    expect(researching.evidence, contains('Three administrators'));
  });
}
