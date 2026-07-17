import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/presentation/idea_evaluation_screen.dart';

void main() {
  testWidgets('evaluation cards fit on a narrow screen with scaled text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime(2026, 7, 17);
    final idea = Idea(
      id: 'responsive-evaluation',
      title: 'Responsive evaluation',
      domain: 'Testing',
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: IdeaEvaluationScreen(idea: idea),
      ),
    );
    await tester.pumpAndSettle();

    final headerRect = tester.getRect(
      find.byKey(const Key('evaluation_score_header')),
    );
    final titleRect = tester.getRect(
      find.byKey(const Key('evaluation_score_title')),
    );
    final explanationRect = tester.getRect(
      find.byKey(const Key('evaluation_score_explanation')),
    );
    final scoreRect = tester.getRect(
      find.byKey(const Key('evaluation_total_score')),
    );

    expect(find.text('Opportunity score'), findsOneWidget);
    expect(find.text('Adjust each criterion from 1 to 5.'), findsOneWidget);
    expect(find.text('24/40'), findsOneWidget);
    expect(scoreRect.top, greaterThanOrEqualTo(explanationRect.bottom));
    expect(scoreRect.overlaps(explanationRect), isFalse);
    expect(headerRect.contains(titleRect.topLeft), isTrue);
    expect(headerRect.contains(titleRect.bottomRight), isTrue);
    expect(headerRect.contains(explanationRect.topLeft), isTrue);
    expect(headerRect.contains(explanationRect.bottomRight), isTrue);
    expect(headerRect.contains(scoreRect.topLeft), isTrue);
    expect(headerRect.contains(scoreRect.bottomRight), isTrue);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Access to first client'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('evaluation_rationale_field')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
