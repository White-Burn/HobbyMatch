import 'package:flutter_test/flutter_test.dart';
import 'package:hobbymatch/main.dart';

void main() {
  testWidgets('App loads onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HobbyMatchApp());
    await tester.pumpAndSettle();

    expect(find.text('Desliza eventos'), findsOneWidget);
    expect(find.text('Empezar'), findsNothing);
    expect(find.text('Siguiente'), findsOneWidget);
  });
}
