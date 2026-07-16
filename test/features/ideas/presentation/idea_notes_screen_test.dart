import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/data/in_memory_idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/presentation/idea_notes_screen.dart';

void main() {
  testWidgets('adds, edits, reloads, and deletes a research note', (
    tester,
  ) async {
    final now = DateTime(2026, 7, 16);
    final idea = Idea(
      id: 'idea-notes',
      title: 'Researchable idea',
      domain: 'Research',
      createdAt: now,
      updatedAt: now,
    );
    final repository = InMemoryIdeaRepository(seedIdeas: [idea]);

    Widget buildApp() {
      return MaterialApp(
        home: IdeaNotesScreen(repository: repository, ideaId: idea.id),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No research notes yet'), findsOneWidget);

    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note_content_field')),
      'Customers currently use spreadsheets.',
    );
    await tester.tap(find.byKey(const Key('save_note_button')));
    await tester.pumpAndSettle();

    expect(find.text('Customers currently use spreadsheets.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Customers currently use spreadsheets.'), findsOneWidget);

    await tester.tap(find.byTooltip('Note actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note_content_field')),
      'Two customers validated the problem.',
    );
    await tester.tap(find.byKey(const Key('save_note_button')));
    await tester.pumpAndSettle();

    expect(find.text('Two customers validated the problem.'), findsOneWidget);

    await tester.tap(find.byTooltip('Note actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No research notes yet'), findsOneWidget);
    expect(await repository.getNotes(idea.id), isEmpty);
  });
}
