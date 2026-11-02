import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const tts = MethodChannel('flutter_tts');

  group('VodicKrozValjevo', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'scriptCode': 'de'});
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(tts, (_) async => 1);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(tts, null);
    });

    testWidgets('restores the saved language', (WidgetTester tester) async {
      await tester.pumpWidget(const VodicKrozValjevo(isFirstRun: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final locale =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).locale;
      expect(locale?.languageCode, 'de');
    });
  });
}
