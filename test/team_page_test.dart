import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fieldshift_ai/core/localization/app_localizations.dart';
import 'package:fieldshift_ai/core/theme/app_theme.dart';
import 'package:fieldshift_ai/data/models/team_member.dart';
import 'package:fieldshift_ai/features/team/team_page.dart';

Widget _buildTestApp({Locale locale = const Locale('ar')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light,
    home: const TeamPage(),
  );
}

void main() {
  group('TeamPage Tests', () {
    test('verifies all 6 real team members are defined without placeholders', () {
      expect(fieldShiftTeam.length, 6);

      final ids = fieldShiftTeam.map((m) => m.id).toList();
      expect(ids, contains('mostafa_neber'));
      expect(ids, contains('seif_maher'));
      expect(ids, contains('yassin_mahmoud'));
      expect(ids, contains('esraa_mohamed'));
      expect(ids, contains('layan_mohamed'));
      expect(ids, contains('mohamed_ahmed'));

      for (final member in fieldShiftTeam) {
        expect(member.nameAr, isNotEmpty);
        expect(member.nameEn, isNotEmpty);
        expect(member.roleAr, isNotEmpty);
        expect(member.roleEn, isNotEmpty);
        expect(member.contributionAr, isNotEmpty);
        expect(member.contributionEn, isNotEmpty);
        expect(member.initials, isNotEmpty);
        expect(member.tags, isNotEmpty);
      }
    });

    testWidgets('renders team page in Arabic with all member names and roles', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('فريق العمل'), findsOneWidget);
      expect(find.text('تحدي ناسا لتطبيقات الفضاء 2026'), findsOneWidget);

      // Check first member (Mostafa Neber)
      expect(find.text('مصطفى نيبر'), findsOneWidget);
      expect(find.text('قائد المشروع والباحث الرئيسي'), findsOneWidget);

      // Scroll to see all members
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('سيف ماهر'), findsOneWidget);
      expect(find.text('ياسين محمود'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('إسراء محمد'), findsOneWidget);
      expect(find.text('ليان محمد'), findsOneWidget);
      expect(find.text('محمد أحمد'), findsOneWidget);
    });

    testWidgets('renders team page in English properly', (tester) async {
      await tester.pumpWidget(_buildTestApp(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Meet Our Team'), findsOneWidget);
      expect(find.text('NASA SPACE APPS CHALLENGE 2026'), findsOneWidget);

      expect(find.text('Mostafa Neber'), findsOneWidget);
      expect(find.text('Project Lead & Researcher'), findsOneWidget);
    });
  });
}
