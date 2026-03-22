import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App renders landing', (WidgetTester tester) async {
    await tester.pumpWidget(const VirtumApp());
    await tester.pumpAndSettle();

    expect(find.text('Your AI Health Companion'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
