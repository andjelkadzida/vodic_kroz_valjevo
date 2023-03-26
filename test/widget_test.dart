import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/main.dart';
import 'package:vodic_kroz_valjevo/localization/supported_languages.dart';
import 'package:vodic_kroz_valjevo/pages/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group('VodicKrozValjevo', () {
    testWidgets('should set language', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VodicKrozValjevo(),
      ));
      VodicKrozValjevo.setLanguage(
          tester.element(find.byType(VodicKrozValjevo)), Locale('en'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should use default language if not set',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VodicKrozValjevo(),
      ));
      await tester.pumpAndSettle();
      expect(
          Localizations.localeOf(tester.element(find.byType(VodicKrozValjevo))),
          equals(Locale('en')));
    });
  });
}
