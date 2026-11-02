import 'dart:io';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_service.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/localization/locale_controller.dart';
import 'package:vodic_kroz_valjevo/pages/about_city.dart';
import 'package:vodic_kroz_valjevo/text_to_speech/speech_controls.dart';
import 'package:vodic_kroz_valjevo/text_to_speech/text_to_speech_config.dart';

import 'support/fake_parse_client.dart';
import 'support/tour_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const tts = MethodChannel('flutter_tts');
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const events = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
  final calls = <MethodCall>[];
  var speechResult = 1;
  var connectivityChecks = 0;

  setUpAll(() async {
    final client = FakeParseClient(makeTourFixtures());
    await Parse().initialize(
      'test-application',
      'https://example.test/parse',
      clientKey: 'test-client',
      appName: 'Test',
      appVersion: '1',
      appPackageName: 'test.app',
      coreStore: CoreStoreMemoryImp(),
      fileDirectory: Directory.systemTemp.path,
      restRetryIntervals: [],
      clientCreator: (
              {required bool sendSessionId,
              SecurityContext? securityContext}) =>
          client,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TourDataService.instance.refresh(TourCollection.aboutCity);
    calls.clear();
    speechResult = 1;
    connectivityChecks = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(tts, (call) async {
      calls.add(call);
      return call.method == 'speak' ? speechResult : 1;
    });
    messenger.setMockMethodCallHandler(connectivity, (_) async {
      connectivityChecks++;
      return ['none'];
    });
    messenger.setMockMethodCallHandler(events, (_) async => null);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(tts, null);
    messenger.setMockMethodCallHandler(connectivity, null);
    messenger.setMockMethodCallHandler(events, null);
  });

  const languages = <_LanguageCase>[
    _LanguageCase(
      locale: Locale('en'),
      selection: 'en',
      readSurface: 'Read Surface aloud',
      surfaceValue: '2,256 ha',
      surfaceSpeech: 'Surface: 2,256 hectares',
      densitySpeech:
          'Population density: 90.79 people per square kilometer in 2022',
      populationSpeech: 'Population: 82,541 people in 2022',
    ),
    _LanguageCase(
      locale: Locale('de'),
      selection: 'de',
      readSurface: 'Fläche vorlesen',
      surfaceValue: '2.256 ha',
      surfaceSpeech: 'Fläche: 2.256 Hektar',
      densitySpeech:
          'Bevölkerungsdichte: 90,79 Einwohner pro Quadratkilometer im Jahr 2022',
      populationSpeech: 'Bevölkerung: 82.541 Einwohner im Jahr 2022',
    ),
    _LanguageCase(
      locale: Locale('sr'),
      selection: 'Latn',
      readSurface: 'Naglas pročitaj: Površina',
      surfaceValue: '2.256 ha',
      surfaceSpeech: 'Površina: 2.256 hektara',
      densitySpeech:
          'Gustina naseljenosti: 90,79 stanovnika po kvadratnom kilometru 2022. godine',
      populationSpeech: 'Broj stanovnika: 82.541 stanovnika 2022. godine',
    ),
    _LanguageCase(
      locale: Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      selection: 'Latn',
      readSurface: 'Naglas pročitaj: Površina',
      surfaceValue: '2.256 ha',
      surfaceSpeech: 'Površina: 2.256 hektara',
      densitySpeech:
          'Gustina naseljenosti: 90,79 stanovnika po kvadratnom kilometru 2022. godine',
      populationSpeech: 'Broj stanovnika: 82.541 stanovnika 2022. godine',
    ),
    _LanguageCase(
      locale: Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
      selection: 'Cyrl',
      readSurface: 'Наглас прочитај: Површина',
      surfaceValue: '2.256 ха',
      surfaceSpeech: 'Површина: 2.256 хектара',
      densitySpeech:
          'Густина насељености: 90,79 становника по квадратном километру 2022. године',
      populationSpeech: 'Број становника: 82.541 становника 2022. године',
    ),
  ];

  for (final language in languages) {
    testWidgets('each city fact is spoken and labeled in ${language.locale}',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        TextToSpeechConfig.instance.setLanguage('test-other-language');
        final controller = LocaleController();
        await controller.select(language.selection);
        controller.dispose();

        await _pumpCity(tester, language.locale);
        final context = tester.element(find.byType(AboutCity));
        final messages = AppLocalizations.of(context)!;
        final facts = _facts(messages);

        expect(messages.readCityFact(messages.surface), language.readSurface);
        expect(messages.citySurfaceValue(2256), language.surfaceValue);
        expect('${facts[0].label}: ${facts[0].spoken}', language.surfaceSpeech);
        expect('${facts[2].label}: ${facts[2].spoken}', language.densitySpeech);
        expect(
            '${facts[3].label}: ${facts[3].spoken}', language.populationSpeech);
        expect(find.byType(SpeechControls), findsNWidgets(7));

        for (var index = 0; index < facts.length; index++) {
          final fact = facts[index];
          final description = '${fact.label}: ${fact.spoken}';
          final read = find.byTooltip(messages.readCityFact(fact.label));
          await tester.ensureVisible(find.text(fact.label));
          await tester.pump();
          expect(find.bySemanticsLabel(description), findsOneWidget);
          await tester.ensureVisible(read);
          await tester.pump();
          expect(read.hitTestable(), findsOneWidget);

          final controls = find.ancestor(
            of: read,
            matching: find.byType(SpeechControls),
          );
          expect(controls, findsOneWidget);
          expect(
            find.descendant(
                of: controls, matching: find.byIcon(Icons.volume_up)),
            findsOneWidget,
          );
          final stop = find.descendant(
            of: controls,
            matching: find.byTooltip(messages.stopReading),
          );
          expect(stop, findsOneWidget);
          expect(tester.getSize(read).shortestSide, greaterThanOrEqualTo(48));
          expect(tester.getSize(stop).shortestSide, greaterThanOrEqualTo(48));

          final readNode = tester.getSemantics(read);
          final stopNode = tester.getSemantics(stop);
          expect(readNode.label, contains(messages.readCityFact(fact.label)));
          expect(stopNode.label, contains(messages.stopReading));
          expect(readNode.getSemanticsData().hasAction(SemanticsAction.tap),
              isTrue);
          expect(stopNode.getSemanticsData().hasAction(SemanticsAction.tap),
              isTrue);

          final checksBefore = connectivityChecks;
          if (index == 0) {
            tester.semantics.tap(find.semantics.byLabel(readNode.label));
          } else if (index == 1) {
            final readIcon = find.descendant(
                of: read, matching: find.byIcon(Icons.volume_up));
            Focus.of(tester.element(readIcon)).requestFocus();
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          } else {
            await tester.tap(read);
          }
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
          await tester.pump();
          final speakCalls =
              calls.where((call) => call.method == 'speak').toList();
          expect(speakCalls, hasLength(index + 1));
          final arguments = speakCalls.last.arguments;
          final spoken = arguments is Map ? arguments['text'] : arguments;
          expect(spoken, description);
          expect(connectivityChecks, checksBefore);

          await tester.ensureVisible(stop);
          await tester.pump();
          if (index == 0) {
            final stopIcon =
                find.descendant(of: stop, matching: find.byIcon(Icons.stop));
            Focus.of(tester.element(stopIcon)).requestFocus();
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          } else {
            await tester.tap(stop);
          }
          await tester.pump();
          expect(calls.where((call) => call.method == 'stop'),
              hasLength(index + 1));
          expect(tester.takeException(), isNull);
        }

        final configuredLanguage =
            calls.firstWhere((call) => call.method == 'setLanguage').arguments;
        final expectedLanguage =
            Platform.isIOS && language.locale.languageCode == 'sr'
                ? 'hr'
                : language.locale.languageCode;
        expect(configuredLanguage, expectedLanguage);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        semantics.dispose();
      }
    });
  }

  testWidgets('changing language updates fact speech and its voice',
      (tester) async {
    final controller = LocaleController();
    try {
      TextToSpeechConfig.instance.setLanguage('test-other-language');
      await controller.select('en');
      await _pumpCity(tester, const Locale('en'));
      var context = tester.element(find.byType(AboutCity));
      var messages = AppLocalizations.of(context)!;
      var read = find.byTooltip(messages.readCityFact(messages.surface));
      await tester.ensureVisible(read);
      await tester.pump();
      await tester.tap(read);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      await controller.select('de');
      await _pumpCity(tester, const Locale('de'));
      context = tester.element(find.byType(AboutCity));
      messages = AppLocalizations.of(context)!;
      read = find.byTooltip(messages.readCityFact(messages.surface));
      await tester.ensureVisible(read);
      await tester.pump();
      await tester.tap(read);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      final languages = calls
          .where((call) => call.method == 'setLanguage')
          .map((call) => call.arguments)
          .toList();
      final spoken = calls.where((call) => call.method == 'speak').map((call) {
        final arguments = call.arguments;
        return arguments is Map ? arguments['text'] : arguments;
      }).toList();
      expect(languages, ['en', 'de']);
      expect(spoken, ['Surface: 2,256 hectares', 'Fläche: 2.256 Hektar']);
      expect(find.byTooltip('Read Surface aloud'), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      controller.dispose();
    }
  });

  const layouts = <_LayoutCase>[
    _LayoutCase('large German portrait', Size(320, 480), Locale('de'), 3),
    _LayoutCase('large English portrait', Size(320, 480), Locale('en'), 3),
    _LayoutCase('large Latin portrait', Size(320, 480),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'), 3),
    _LayoutCase('large Cyrillic portrait', Size(320, 480),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'), 3),
    _LayoutCase('phone landscape', Size(640, 360), Locale('en'), 2),
    _LayoutCase('tablet landscape', Size(1280, 800), Locale('de'), 1),
  ];

  for (final layout in layouts) {
    testWidgets('city fact controls remain reachable on ${layout.name}',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpCity(tester, layout.locale,
            size: layout.size, textScale: layout.textScale);
        final context = tester.element(find.byType(AboutCity));
        final messages = AppLocalizations.of(context)!;
        for (final fact in _facts(messages)) {
          final label = find.text(fact.label);
          final value = find.text(fact.value);
          final read = find.byTooltip(messages.readCityFact(fact.label));
          await tester.ensureVisible(label);
          await tester.pump();
          final labelRender = tester.renderObject<RenderParagraph>(label);
          expect(labelRender.didExceedMaxLines, isFalse);
          await tester.ensureVisible(value);
          await tester.pump();
          final valueRender = tester.renderObject<RenderParagraph>(value);
          expect(valueRender.didExceedMaxLines, isFalse);
          await tester.ensureVisible(read);
          await tester.pump();
          expect(read.hitTestable(), findsOneWidget);
          expect(tester.getSize(read).shortestSide, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);
        }
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      } finally {
        semantics.dispose();
      }
    });
  }

  testWidgets('an unavailable voice reports a localized error for a fact',
      (tester) async {
    speechResult = 0;
    await _pumpCity(tester, const Locale('de'));
    final context = tester.element(find.byType(AboutCity));
    final messages = AppLocalizations.of(context)!;
    final read = find.byTooltip(messages.readCityFact(messages.surface));
    await tester.ensureVisible(read);
    await tester.pump();
    await tester.tap(read);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text(messages.speechUnavailable), findsOneWidget);
    expect(find.text(messages.ok), findsOneWidget);
  });
}

Future<void> _pumpCity(WidgetTester tester, Locale locale,
    {Size size = const Size(390, 844), double textScale = 1}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: const AboutCity(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

List<_ExpectedFact> _facts(AppLocalizations messages) => [
      _ExpectedFact(messages.surface, messages.citySurfaceValue(2256),
          messages.citySurfaceSpoken(2256)),
      _ExpectedFact(messages.elevation, messages.cityElevationValue(185),
          messages.cityElevationSpoken(185)),
      _ExpectedFact(
        messages.populationDensity,
        messages.cityDensityValue(90.79, 2022),
        messages.cityDensitySpoken(90.79, 2022),
      ),
      _ExpectedFact(
        messages.population,
        messages.cityPopulationValue(82541, 2022),
        messages.cityPopulationSpoken(82541, 2022),
      ),
      _ExpectedFact(messages.district, messages.kolubaraDistrict,
          messages.kolubaraDistrict),
      _ExpectedFact(
          messages.cityDay, messages.cityDayDate, messages.cityDayDate),
      _ExpectedFact(messages.saint, messages.saintName, messages.saintName),
    ];

class _ExpectedFact {
  const _ExpectedFact(this.label, this.value, this.spoken);

  final String label;
  final String value;
  final String spoken;
}

class _LanguageCase {
  const _LanguageCase({
    required this.locale,
    required this.selection,
    required this.readSurface,
    required this.surfaceValue,
    required this.surfaceSpeech,
    required this.densitySpeech,
    required this.populationSpeech,
  });

  final Locale locale;
  final String selection;
  final String readSurface;
  final String surfaceValue;
  final String surfaceSpeech;
  final String densitySpeech;
  final String populationSpeech;
}

class _LayoutCase {
  const _LayoutCase(this.name, this.size, this.locale, this.textScale);

  final String name;
  final Size size;
  final Locale locale;
  final double textScale;
}
