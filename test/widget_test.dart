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
}
