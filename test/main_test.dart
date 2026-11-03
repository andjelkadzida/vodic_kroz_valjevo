import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodic_kroz_valjevo/localization/language.dart';
import 'package:vodic_kroz_valjevo/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const tts = MethodChannel('flutter_tts');

  group('VodicKrozValjevo', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(tts, (_) async => 1);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(tts, null);
    });

    testWidgets('uses Serbian Cyrillic when no language is saved',
        (WidgetTester tester) async {
      await tester.pumpWidget(const VodicKrozValjevo(isFirstRun: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final locale =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).locale;
      expect(locale?.languageCode, 'sr');
      expect(locale?.scriptCode, 'Cyrl');
    });

    testWidgets('language selection updates the app and preferences',
        (tester) async {
      await tester.pumpWidget(const VodicKrozValjevo(isFirstRun: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();
      final german = find.byWidgetPredicate(
        (widget) =>
            widget is LanguageButton && widget.language.scriptCode == 'de',
      );
      await tester.ensureVisible(german);
      await tester.tap(german);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      final locale =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).locale;
      expect(locale?.languageCode, 'de');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('scriptCode'), 'de');
      expect(prefs.getBool('isFirstRun'), isFalse);
    });
  });
}
