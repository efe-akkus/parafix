import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parafix/app/parafix_app.dart';

void main() {
  testWidgets('Parafix renders onboarding on first launch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ParafixApp());
    await tester.pumpAndSettle();

    expect(find.text('Harcamalarını hızlıca kaydet'), findsOneWidget);
    expect(find.text('İleri'), findsOneWidget);
    expect(find.text('Geri'), findsOneWidget);
  });

  testWidgets('Parafix shell renders main navigation', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'parafix_has_seen_onboarding_v1': true,
    });

    await tester.pumpWidget(const ParafixApp());
    await tester.pumpAndSettle();

    expect(find.text('Parafix'), findsOneWidget);
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Rapor'), findsOneWidget);
  });
}
