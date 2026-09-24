import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/questions/domain/question.dart';

void main() {
  test('new question is open by default', () {
    final now = DateTime(2026, 9, 23);
    final question = Question(
      id: 'q1',
      title: 'What should we validate?',
      createdAt: now,
      updatedAt: now,
    );

    expect(question.status, QuestionStatus.open);
    expect(question.isAnswered, isFalse);
    expect(question.answer, isEmpty);
  });

  test('answered question reports answered state', () {
    final now = DateTime(2026, 9, 23);
    final question = Question(
      id: 'q1',
      title: 'Will customers pay?',
      answer: 'Yes, after five interviews.',
      status: QuestionStatus.answered,
      createdAt: now,
      updatedAt: now,
      answeredAt: now,
    );

    expect(question.isAnswered, isTrue);
    expect(question.answeredAt, now);
  });

  test('copyWith can reopen an answered question', () {
    final now = DateTime(2026, 9, 23);
    final question = Question(
      id: 'q1',
      title: 'Will customers pay?',
      status: QuestionStatus.answered,
      createdAt: now,
      updatedAt: now,
      answeredAt: now,
    );

    final reopened = question.copyWith(
      status: QuestionStatus.open,
      clearAnsweredAt: true,
    );

    expect(reopened.status, QuestionStatus.open);
    expect(reopened.answeredAt, isNull);
  });
}
