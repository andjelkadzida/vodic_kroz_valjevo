import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/text_to_speech/speech_controls.dart';
import 'package:vodic_kroz_valjevo/text_to_speech/text_to_speech_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const tts = MethodChannel('flutter_tts');
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const settings = MethodChannel('com.spencerccf.app_settings/methods');
  final calls = <String>[];
  var speechResult = 1;
  var languageResult = 1;
  var connectivityChecks = 0;
  var settingsCalls = 0;

  setUp(() {
    calls.clear();
    speechResult = 1;
    languageResult = 1;
    connectivityChecks = 0;
    settingsCalls = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(tts, (call) async {
      calls.add(call.method);
      if (call.method == 'setLanguage') return languageResult;
      return call.method == 'speak' ? speechResult : 1;
    });
    messenger.setMockMethodCallHandler(connectivity, (_) async {
      connectivityChecks++;
      return ['none'];
    });
    messenger.setMockMethodCallHandler(settings, (_) async {
      settingsCalls++;
      return null;
    });
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(tts, null);
    messenger.setMockMethodCallHandler(connectivity, null);
    messenger.setMockMethodCallHandler(settings, null);
  });

  testWidgets('reading and stopping are labeled and work without internet',
      (tester) async {
    await _pumpControls(tester);
    final context = tester.element(find.byType(SpeechControls));
    final stop = AppLocalizations.of(context)!.stopReading;
    await tester.tap(find.byTooltip('Read description'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(calls, contains('speak'));
    expect(connectivityChecks, 0);
    expect(settingsCalls, 0);
    await tester.tap(find.byTooltip(stop));
    await tester.pump();
    expect(calls, contains('stop'));
  });

  testWidgets('speech failures are reported in the selected language',
      (tester) async {
    speechResult = 0;
    await _pumpControls(tester, accessibleNavigation: true);
    await tester.tap(find.byTooltip('Read description'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    final context = tester.element(find.byType(SpeechControls));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.speechUnavailable), findsOneWidget);
    expect(find.text(messages.ok), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text(messages.speechUnavailable), findsOneWidget);
    await tester.tap(find.text(messages.ok));
    await tester.pumpAndSettle();
    expect(find.text(messages.speechUnavailable), findsNothing);
  });

  testWidgets('an unavailable voice is reported rather than silently used',
      (tester) async {
    languageResult = 0;
    TextToSpeechConfig.instance.setLanguage('unavailable');
    await _pumpControls(tester);
    await tester.tap(find.byTooltip('Read description'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    final context = tester.element(find.byType(SpeechControls));
    expect(find.text(AppLocalizations.of(context)!.speechUnavailable),
        findsOneWidget);
    expect(calls, isNot(contains('speak')));
  });
}

Future<void> _pumpControls(WidgetTester tester,
    {bool accessibleNavigation = false}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(accessibleNavigation: accessibleNavigation),
        child: child!,
      ),
      home: const Scaffold(
        body: SpeechControls(text: 'Example', readLabel: 'Read description'),
      ),
    ),
  );
}
