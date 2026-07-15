import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/app/idea_radar_app.dart';

void main() {
  testWidgets('shows the IdeaRadar dashboard', (tester) async {
    await tester.pumpWidget(const IdeaRadarApp());

    expect(find.text('IdeaRadar'), findsOneWidget);
    expect(find.text('From idea to opportunity.'), findsOneWidget);
    expect(find.text('Add your first idea'), findsOneWidget);
    expect(find.text('New idea'), findsOneWidget);
  });

  testWidgets('validates and adds a new idea', (tester) async {
    await tester.pumpWidget(const IdeaRadarApp());

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
  });
}
