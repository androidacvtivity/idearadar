import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/app/idea_radar_app.dart';
import 'package:idearadar/features/ideas/data/in_memory_idea_repository.dart';

Future<InMemoryIdeaRepository> pumpIdeaRadar(WidgetTester tester) async {
  final repository = InMemoryIdeaRepository();
  await tester.pumpWidget(IdeaRadarApp(repository: repository));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('shows the IdeaRadar dashboard', (tester) async {
    await pumpIdeaRadar(tester);

    expect(find.text('IdeaRadar'), findsOneWidget);
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
    await tester.tap(find.byKey(const Key('save_idea_button')));
    await tester.pumpAndSettle();

    expect(find.text('Mobile client portal'), findsOneWidget);
    expect(find.text('Business services · New'), findsOneWidget);
    expect(find.text('Your idea radar is ready'), findsNothing);

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
  });
}
