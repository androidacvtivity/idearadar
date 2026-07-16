import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/data/in_memory_idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/presentation/idea_sources_screen.dart';

void main() {
  testWidgets('adds, edits, reloads, and deletes a research source', (
    tester,
  ) async {
    final now = DateTime(2026, 7, 16);
    final idea = Idea(
      id: 'idea-sources',
      title: 'Researchable idea',
      domain: 'Research',
      createdAt: now,
      updatedAt: now,
    );
    final repository = InMemoryIdeaRepository(seedIdeas: [idea]);

    Widget buildApp() {
      return MaterialApp(
        home: IdeaSourcesScreen(repository: repository, ideaId: idea.id),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No research sources yet'), findsOneWidget);

    await tester.tap(find.text('New source'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('source_title_field')),
      'Agriculture market report',
    );
    await tester.enterText(
      find.byKey(const Key('source_url_field')),
      'https://example.com/report',
    );
    await tester.tap(find.byKey(const Key('save_source_button')));
    await tester.pumpAndSettle();

    expect(find.text('Agriculture market report'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Agriculture market report'), findsOneWidget);

    await tester.tap(find.text('Agriculture market report'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('source_title_field')),
      'Updated agriculture report',
    );
    await tester.tap(find.byKey(const Key('save_source_button')));
    await tester.pumpAndSettle();

    expect(find.text('Updated agriculture report'), findsOneWidget);

    await tester.tap(find.byTooltip('Source actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No research sources yet'), findsOneWidget);
    expect(await repository.getSources(idea.id), isEmpty);
  });
}
