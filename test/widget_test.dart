import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/app.dart';

void main() {
  testWidgets('Sf6App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Sf6App());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(Sf6App), findsOneWidget);
  });
}
