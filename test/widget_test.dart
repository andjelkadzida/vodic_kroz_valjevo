import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vodic_kroz_valjevo/database_config/database_helper.dart';
import 'package:vodic_kroz_valjevo/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  sqfliteFfiInit(); // Initialize sqflite_ffi

  group('VodicKrozValjevo', () {
    testWidgets('should use default language if not set',
        (WidgetTester tester) async {
      databaseFactory = databaseFactoryFfi;
      final db = await DatabaseHelper.instance.getNamedDatabase();
      bool isFirstRun = true;
      late Locale defaultLocale;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext buildContext) {
              defaultLocale = Localizations.localeOf(buildContext);
              return VodicKrozValjevo(database: db, isFirstRun: isFirstRun);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        Localizations.localeOf(tester.element(find.byType(VodicKrozValjevo))),
        equals(defaultLocale),
      );
    });
  });
}
