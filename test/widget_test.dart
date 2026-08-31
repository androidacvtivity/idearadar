import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/app/idea_radar_app.dart';
import 'package:idearadar/features/ideas/data/in_memory_idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_evaluation.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';

Future<InMemoryIdeaRepository> pumpIdeaRadar(WidgetTester tester) async {
  final repository = InMemoryIdeaRepository();
  await tester.pumpWidget(IdeaRadarApp(repository: repository));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('shows the Idea Tracker dashboard', (tester) async {
    await pumpIdeaRadar(tester);

    expect(find.text('Idea Tracker'), findsOneWidget);
    expect(find.text('From idea to opportunity.'), findsOneWidget);
    expect(find.text('Add your first idea'), findsOneWidget);
    expect(find.text('New idea'), findsOneWidget);
  });

  testWidgets('validates, adds, and reloads a new idea', (tester) async {
    final repository = await pumpIdeaRadar(tester);

    await tester.tap(find.text('New idea'));
    await tester.pumpAndSettle();

    expect(find.text('Add new idea'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save_idea_button')));
    await tester.pump();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Domain is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('idea_title_field')),
      'Mobile client portal',
    );
    await tester.enterText(
      find.byKey(const Key('idea_domain_field')),
      'Business services',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('idea_target_users_field')),
      'Small business owners and their staff',
    );
    await tester.enterText(
      find.byKey(const Key('idea_paying_customer_field')),
      'The business owner',
    );
    await tester.tap(find.byKey(const Key('save_idea_button')));
    await tester.pumpAndSettle();

    expect(find.text('Mobile client portal'), findsOneWidget);
    expect(find.text('Business services · New'), findsOneWidget);
    expect(find.text('Your idea radar is ready'), findsNothing);

    final savedIdea = (await repository.getIdeas()).single;
    expect(savedIdea.targetUsers, 'Small business owners and their staff');
    expect(savedIdea.payingCustomer, 'The business owner');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Mobile client portal'), findsOneWidget);

    await tester.tap(find.text('Mobile client portal'));
    await tester.pumpAndSettle();

    expect(find.text('Idea details'), findsOneWidget);
    expect(find.text('Business services'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Not evaluated'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit idea'));
    await tester.pumpAndSettle();

    expect(find.text('Edit idea'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('idea_title_field')),
      'Updated mobile client portal',
    );
    await tester.tap(find.byKey(const Key('save_idea_button')));
    await tester.pumpAndSettle();

    expect(find.text('Updated mobile client portal'), findsOneWidget);
    expect(find.text('Mobile client portal'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Updated mobile client portal'), findsOneWidget);

    await tester.tap(find.text('Updated mobile client portal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not evaluated'));
    await tester.pumpAndSettle();

    expect(find.text('Evaluate idea'), findsOneWidget);
    expect(find.text('24/40'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save_evaluation_button')));
    await tester.pumpAndSettle();

    expect(find.text('24/40'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('24/40'), findsOneWidget);
  });

  testWidgets('searches ideas by domain and opens the result', (tester) async {
    final now = DateTime(2026, 7, 15);
    final repository = InMemoryIdeaRepository(
      seedIdeas: [
        Idea(
          id: 'idea-agriculture',
          title: 'Offline farm journal',
          domain: 'Agriculture',
          summary: 'Track field work without a permanent internet connection.',
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Search ideas'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'agriculture');
    await tester.pumpAndSettle();

    expect(find.text('Offline farm journal'), findsOneWidget);

    await tester.tap(find.text('Offline farm journal'));
    await tester.pumpAndSettle();

    expect(find.text('Idea details'), findsOneWidget);
    expect(find.text('Agriculture'), findsOneWidget);
  });

  testWidgets('confirms and permanently deletes an idea', (tester) async {
    final now = DateTime(2026, 7, 15);
    final repository = InMemoryIdeaRepository(
      seedIdeas: [
        Idea(
          id: 'idea-delete',
          title: 'Idea to delete',
          domain: 'Testing',
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idea to delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete idea'));
    await tester.pumpAndSettle();

    expect(find.text('Delete idea?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Idea to delete'), findsNothing);
    expect(find.text('Your idea radar is ready'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Idea to delete'), findsNothing);
  });

  testWidgets('filters by status and sorts ideas by score', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime(2026, 7, 16);
    IdeaEvaluation evaluation(int score) {
      return IdeaEvaluation(
        problemScore: score,
        marketScore: score,
        demandScore: score,
        competitionScore: score,
        dataAccessScore: score,
        technicalFeasibilityScore: score,
        monetizationScore: score,
        firstClientScore: score,
      );
    }

    final repository = InMemoryIdeaRepository(
      seedIdeas: [
        Idea(
          id: 'high-score',
          title: 'High scoring validated idea',
          domain: 'Education',
          status: IdeaStatus.validated,
          evaluation: evaluation(5),
          createdAt: now,
          updatedAt: now,
        ),
        Idea(
          id: 'medium-score',
          title: 'Medium scoring research idea',
          domain: 'Agriculture',
          status: IdeaStatus.researching,
          evaluation: evaluation(3),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Idea(
          id: 'not-evaluated',
          title: 'New unevaluated idea',
          domain: 'Community',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
      ],
    );

    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filter and sort ideas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('idea_status_filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Validated').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('apply_idea_filters_button')));
    await tester.pumpAndSettle();

    expect(find.text('High scoring validated idea'), findsOneWidget);
    expect(find.text('Medium scoring research idea'), findsNothing);
    expect(find.text('1 of 3'), findsOneWidget);

    await tester.tap(find.byTooltip('Filter and sort ideas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reset_idea_filters_button')));
    await tester.tap(find.byKey(const Key('idea_sort_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest score').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('apply_idea_filters_button')));
    await tester.pumpAndSettle();

    final highPosition = tester.getTopLeft(
      find.text('High scoring validated idea'),
    );
    final mediumPosition = tester.getTopLeft(
      find.text('Medium scoring research idea'),
    );
    expect(highPosition.dy, lessThan(mediumPosition.dy));
    expect(find.text('3 of 3'), findsOneWidget);
  });

  testWidgets('schedules and clears the next review date', (tester) async {
    final now = DateTime.now();
    final repository = InMemoryIdeaRepository(
      seedIdeas: [
        Idea(
          id: 'idea-review',
          title: 'Idea requiring review',
          domain: 'Planning',
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idea requiring review'));
    await tester.pumpAndSettle();
    final nextReviewTile = find.byKey(const Key('next_review_tile'));
    await tester.ensureVisible(nextReviewTile);
    await tester.pumpAndSettle();
    await tester.tap(nextReviewTile);
    await tester.pumpAndSettle();

    expect(find.text('Select next review date'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    var savedIdea = (await repository.getIdeas()).single;
    expect(savedIdea.nextReviewAt, isNotNull);
    expect(find.textContaining('Review '), findsOneWidget);

    await tester.tap(find.text('Idea requiring review'));
    await tester.pumpAndSettle();
    final clearReviewButton = find.byKey(
      const Key('clear_next_review_button'),
    );
    await tester.ensureVisible(clearReviewButton);
    await tester.pumpAndSettle();
    await tester.tap(clearReviewButton);
    await tester.pumpAndSettle();

    expect(find.text('Remove review date?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    savedIdea = (await repository.getIdeas()).single;
    expect(savedIdea.nextReviewAt, isNull);
    expect(find.textContaining('Review '), findsNothing);
  });

  testWidgets('archives and restores an idea', (tester) async {
    final now = DateTime(2026, 7, 16);
    final repository = InMemoryIdeaRepository(
      seedIdeas: [
        Idea(
          id: 'idea-archive',
          title: 'Idea to archive',
          domain: 'Planning',
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    await tester.pumpWidget(IdeaRadarApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Idea to archive'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive idea'));
    await tester.pumpAndSettle();

    expect(find.text('Archive idea?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Idea to archive'), findsNothing);
    expect((await repository.getIdeas()).single.isArchived, isTrue);

    await tester.tap(find.byTooltip('Archived ideas'));
    await tester.pumpAndSettle();

    expect(find.text('Idea to archive'), findsOneWidget);
    await tester.tap(find.text('Idea to archive'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore idea'));
    await tester.pumpAndSettle();

    expect(find.text('Restore idea?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await tester.pumpAndSettle();

    expect(find.text('No archived ideas'), findsOneWidget);
    expect((await repository.getIdeas()).single.isArchived, isFalse);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Idea to archive'), findsOneWidget);
  });
}
