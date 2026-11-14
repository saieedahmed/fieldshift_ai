import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fieldshift_ai/main.dart';

void main() {
  testWidgets('opens on the demo farm and switches to Arabic immediately', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FieldShiftApp());
    await tester.pumpAndSettle();

    expect(find.text('Green Valley Farm'), findsOneWidget);
    expect(find.text('DEMO DATA'), findsOneWidget);
    expect(find.text('Water stress detected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Farm information'), findsOneWidget);

    await tester.ensureVisible(find.text('العربية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsWidgets);
    expect(find.text('المصيلحة، المنوفية، مصر'), findsWidgets);
    await tester.drag(find.byType(ListView).last, const Offset(0, 700));
    await tester.pumpAndSettle();
    expect(find.text('معلومات المزرعة'), findsOneWidget);
  });

  testWidgets('insights switch between satellite and climate views', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FieldShiftApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.text('A closer look'), findsOneWidget);

    await tester.tap(find.text('Satellite'));
    await tester.pumpAndSettle();
    expect(find.text('0.71'), findsWidgets);
    expect(find.text('What is NDVI?'), findsOneWidget);

    await tester.tap(find.text('Climate'));
    await tester.pumpAndSettle();
    expect(find.text('Temperature trend'), findsOneWidget);
    expect(find.textContaining('34'), findsWidgets);
  });
}
