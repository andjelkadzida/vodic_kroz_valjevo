import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/main.dart' show appLocalizationsDelegates;
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
  var autoStart = true;
  var autoPause = true;
  Completer<void>? stopCompleter;
  Completer<void>? speakCompleter;
  Completer<void>? preparationCompleter;

  setUp(() async {
    calls.clear();
    speechResult = 1;
    languageResult = 1;
    connectivityChecks = 0;
    settingsCalls = 0;
    autoStart = true;
    autoPause = true;
    stopCompleter = null;
    speakCompleter = null;
    preparationCompleter = null;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(tts, (call) async {
      calls.add(call.method);
      if (call.method == 'setLanguage') return languageResult;
      if (call.method == 'stop' && stopCompleter != null) {
        await stopCompleter!.future;
      }
      if (call.method == 'awaitSpeakCompletion' &&
          preparationCompleter != null) {
        await preparationCompleter!.future;
      }
      if (call.method == 'speak' && speechResult == 1) {
        if (autoStart) {
          TextToSpeechConfig.instance.flutterTts.startHandler?.call();
        }
        if (speakCompleter != null) await speakCompleter!.future;
      }
      if (call.method == 'pause' && autoPause) {
        TextToSpeechConfig.instance.flutterTts.pauseHandler?.call();
      }
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
    await TextToSpeechConfig.instance.stopSpeaking();
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

  testWidgets('pause and resume remain available without playback callbacks',
      (tester) async {
    autoStart = false;
    autoPause = false;
    await _pumpControls(tester);
    final context = tester.element(find.byType(SpeechControls));
    final messages = AppLocalizations.of(context)!;

    await tester.tap(find.byTooltip('Read description'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
    expect(find.byTooltip(messages.stopReading), findsOneWidget);

    await tester.tap(find.byTooltip(messages.pauseReading));
    await tester.pump();
    expect(calls, contains('pause'));
    expect(find.byTooltip(messages.resumeReading), findsOneWidget);

    await tester.tap(find.byTooltip(messages.resumeReading));
    await tester.pump();
    expect(calls.where((call) => call == 'speak'), hasLength(2));
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
  });

  testWidgets('buttons follow playback before the speak call returns',
      (tester) async {
    speakCompleter = Completer<void>();
    await _pumpControls(tester);
    final context = tester.element(find.byType(SpeechControls));
    final messages = AppLocalizations.of(context)!;

    await tester.tap(find.byTooltip('Read description'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
    expect(find.byTooltip(messages.stopReading), findsOneWidget);

    TextToSpeechConfig.instance.flutterTts.completionHandler?.call();
    await tester.pump();
    expect(find.byTooltip('Read description'), findsOneWidget);
    expect(find.byTooltip(messages.stopReading), findsNothing);

    speakCompleter!.complete();
    await tester.pump();
    expect(find.byTooltip('Read description'), findsOneWidget);
  });

  testWidgets('pause is available during preparation and resume starts once',
      (tester) async {
    preparationCompleter = Completer<void>();
    await _pumpControls(tester);
    final context = tester.element(find.byType(SpeechControls));
    final messages = AppLocalizations.of(context)!;

    await tester.tap(find.byTooltip('Read description'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
    expect(find.byTooltip(messages.stopReading), findsOneWidget);
    expect(calls, isNot(contains('speak')));

    await tester.tap(find.byTooltip(messages.pauseReading));
    await tester.pump();
    expect(find.byTooltip(messages.resumeReading), findsOneWidget);
    expect(calls, isNot(contains('pause')));

    await tester.tap(find.byTooltip(messages.resumeReading));
    await tester.pump();
    preparationCompleter!.complete();
    await tester.pump();
    await tester.pump();
    expect(calls.where((call) => call == 'speak'), hasLength(1));
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
  });

  testWidgets('starting can be stopped and keeps the primary button focused',
      (tester) async {
    autoStart = false;
    speakCompleter = Completer<void>();
    await _pumpControls(tester);
    final context = tester.element(find.byType(SpeechControls));
    final messages = AppLocalizations.of(context)!;
    final readButton = find.byTooltip('Read description');
    final readIcon = find.descendant(
        of: readButton, matching: find.byIcon(Icons.play_arrow));
    Focus.of(tester.element(readIcon)).requestFocus();
    await tester.pump();

    await tester.tap(readButton);
    await tester.pump(const Duration(milliseconds: 350));
    final stopButton = find.byTooltip(messages.stopReading);
    expect(stopButton, findsOneWidget);
    final pauseButton = find.byTooltip(messages.pauseReading);
    expect(pauseButton, findsOneWidget);
    final primary = find.ancestor(
      of: pauseButton,
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(primary).focusNode!.hasFocus, isTrue);

    await tester.tap(stopButton);
    await tester.pump();
    TextToSpeechConfig.instance.flutterTts.startHandler?.call();
    speakCompleter!.complete();
    await tester.pump();
    expect(find.byTooltip('Read description'), findsOneWidget);
    expect(find.byTooltip(messages.stopReading), findsNothing);
    expect(
        tester
            .widget<IconButton>(find.ancestor(
              of: find.byTooltip('Read description'),
              matching: find.byType(IconButton),
            ))
            .focusNode!
            .hasFocus,
        isTrue);
  });

  testWidgets('pause and resume buttons follow native playback events',
      (tester) async {
    autoStart = false;
    speakCompleter = Completer<void>();
    await _pumpControls(tester);
    final context = tester.element(find.byType(SpeechControls));
    final messages = AppLocalizations.of(context)!;

    await tester.tap(find.byTooltip('Read description'));
    await tester.pump(const Duration(milliseconds: 350));
    TextToSpeechConfig.instance.flutterTts.startHandler?.call();
    await tester.pump();
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
    expect(find.byTooltip(messages.stopReading), findsOneWidget);
    speakCompleter!.complete();
    await tester.pump();

    await tester.tap(find.byTooltip(messages.pauseReading));
    await tester.pump();
    expect(find.byTooltip(messages.resumeReading), findsOneWidget);

    speakCompleter = Completer<void>();
    await tester.tap(find.byTooltip(messages.resumeReading));
    await tester.pump();
    expect(TextToSpeechConfig.instance.isStarting, isTrue);
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
    expect(find.byTooltip(messages.stopReading), findsOneWidget);
    TextToSpeechConfig.instance.flutterTts.continueHandler?.call();
    await tester.pump();
    expect(TextToSpeechConfig.instance.isPlaying, isTrue);
    expect(find.byTooltip(messages.pauseReading), findsOneWidget);
    speakCompleter!.complete();
    await tester.pump();
  });

  testWidgets('stopping moves focus from Stop to the primary action',
      (tester) async {
    await _pumpControls(tester);
    final context = tester.element(find.byType(SpeechControls));
    final messages = AppLocalizations.of(context)!;
    final readButton = find.byTooltip('Read description');
    Focus.of(tester.element(find.descendant(
      of: readButton,
      matching: find.byIcon(Icons.play_arrow),
    ))).requestFocus();
    await tester.tap(readButton);
    await tester.pump(const Duration(milliseconds: 350));

    final pauseButton = find.byTooltip(messages.pauseReading);
    final primary = find.ancestor(
      of: pauseButton,
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(primary).focusNode!.hasFocus, isTrue);

    final stopButton = find.byTooltip(messages.stopReading);
    final stopIcon =
        find.descendant(of: stopButton, matching: find.byIcon(Icons.stop));
    Focus.of(tester.element(stopIcon)).requestFocus();
    await tester.pump();
    expect(Focus.of(tester.element(stopIcon)).hasFocus, isTrue);

    stopCompleter = Completer<void>();
    await tester.tap(stopButton);
    await tester.pump();

    expect(tester.widget<IconButton>(primary).focusNode!.hasFocus, isTrue);

    stopCompleter!.complete();
    await tester.pumpAndSettle();
    final readAgainButton = find.byTooltip('Read description');
    expect(
      tester
          .widget<IconButton>(find.ancestor(
            of: readAgainButton,
            matching: find.byType(IconButton),
          ))
          .focusNode!
          .hasFocus,
      isTrue,
    );
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
      localizationsDelegates: appLocalizationsDelegates,
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
