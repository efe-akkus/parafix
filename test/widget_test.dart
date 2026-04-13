import 'package:flutter_test/flutter_test.dart';

import 'package:parafix/app/parafix_app.dart';

void main() {
  testWidgets('Parafix shell renders main navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ParafixApp());
    await tester.pumpAndSettle();

    expect(find.text('Parafix'), findsOneWidget);
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Rapor'), findsOneWidget);
  });
}
