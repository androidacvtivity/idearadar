import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/data/in_memory_idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/problems/domain/problem.dart';
import 'package:idearadar/features/problems/domain/problem_idea_link.dart';
import 'package:idearadar/features/problems/domain/problem_question_link.dart';
import 'package:idearadar/features/questions/domain/question.dart';

void main() {
  test('problem can link independently to a question and an idea', () async {
    final now = DateTime(2026, 9, 27);
    final problem = Problem(
      id: 'problem-1',
      title: 'Communication is fragmented',
      createdAt: now,
      updatedAt: now,
    );
    final question = Question(
      id: 'question-1',
      title: 'How do residents receive urgent notices today?',
      createdAt: now,
      updatedAt: now,
    );
    final idea = Idea(
      id: 'idea-1',
      title: 'Condominium communication app',
      domain: 'Community',
      createdAt: now,
      updatedAt: now,
    );

    final repository = InMemoryIdeaRepository(
      seedProblems: [problem],
      seedQuestions: [question],
      seedIdeas: [idea],
    );

    await repository.addProblemQuestionLink(
      ProblemQuestionLink(
        problemId: problem.id,
        questionId: question.id,
        relationType: ProblemQuestionRelationType.problemCreatedQuestion,
        createdAt: now,
      ),
    );
    await repository.addProblemIdeaLink(
      ProblemIdeaLink(
        problemId: problem.id,
        ideaId: idea.id,
        relationType: ProblemIdeaRelationType.problemCreatedIdea,
        createdAt: now,
      ),
    );

    expect(
      await repository.getProblemQuestionLinks(problemId: problem.id),
      hasLength(1),
    );
    expect(
      await repository.getProblemIdeaLinks(problemId: problem.id),
      hasLength(1),
    );
  });

  test('deleting a problem clears its in-memory links', () async {
    final now = DateTime(2026, 9, 27);
    final repository = InMemoryIdeaRepository(
      seedProblems: [
        Problem(
          id: 'problem-1',
          title: 'Communication is fragmented',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      seedQuestions: [
        Question(
          id: 'question-1',
          title: 'How is this handled today?',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      seedProblemQuestionLinks: [
        ProblemQuestionLink(
          problemId: 'problem-1',
          questionId: 'question-1',
          relationType: ProblemQuestionRelationType.related,
          createdAt: now,
        ),
      ],
    );

    await repository.deleteProblem('problem-1');

    expect(await repository.getProblems(), isEmpty);
    expect(await repository.getProblemQuestionLinks(), isEmpty);
  });
}
