import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'
    show ParseError;
import 'package:vodic_kroz_valjevo/helper/internet_connectivity.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/pages/bug_report.dart';

void main() {
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const settings = MethodChannel('com.spencerccf.app_settings/methods');
  var online = true;

  setUp(() {
    online = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivity,
      (_) async => [online ? 'wifi' : 'none'],
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivity, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settings, null);
  });

  testWidgets('keeps form data while sending and resets only after success',
      (tester) async {
    final request = Completer<void>();
    var submissions = 0;
    await _pumpForm(tester, sender: (title, description, os, file) {
      submissions++;
      expect(title, 'A title');
      expect(description, 'A description');
      expect(os, 'Android');
      return request.future;
    });
    await _fillForm(tester);
    await _submit(tester);
    expect(submissions, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_titleText(tester), 'A title');

    request.complete();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(_titleText(tester), isEmpty);
    expect(find.text('A description'), findsNothing);
  });

  testWidgets('keeps form data and reports a failed submission',
      (tester) async {
    await _pumpForm(tester, sender: (_, __, ___, ____) async {
      throw StateError('failed');
    });
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    await tester.pump();
    expect(_titleText(tester), 'A title');
    final context = tester.element(find.byType(BugReportPage));
    expect(find.text(AppLocalizations.of(context)!.submissionFailed),
        findsOneWidget);
  });

  testWidgets('does not send when connectivity is unavailable', (tester) async {
    online = false;
    var submissions = 0;
    await _pumpForm(tester, sender: (_, __, ___, ____) async => submissions++);
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    await tester.pump();
    expect(submissions, 0);
    expect(_titleText(tester), 'A title');
    final context = tester.element(find.byType(BugReportPage));
    expect(find.text(AppLocalizations.of(context)!.noInternetConnection),
        findsOneWidget);
  });

  testWidgets('offers settings if the connection drops during submission',
      (tester) async {
    final request = Completer<void>();
    final settingsCalls = <MethodCall>[];
    var submissions = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settings, (call) async {
      settingsCalls.add(call);
      return null;
    });
    await _pumpForm(tester, sender: (_, __, ___, ____) {
      submissions++;
      return request.future;
    });
    await _fillForm(tester);
    await _submit(tester);
    online = false;
    request.completeError(const SocketException('connection lost'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.noInternetConnection), findsOneWidget);
    expect(_titleText(tester), 'A title');
    expect(submissions, 1);
    await tester.tap(find.text(messages.openSettings));
    await tester.pump();
    expect(settingsCalls.single.method, 'openSettings');
    expect((settingsCalls.single.arguments as Map)['type'], 'wireless');
  });

  testWidgets('a failed connection on Wi-Fi offers guidance', (tester) async {
    await _pumpForm(tester, sender: (_, __, ___, ____) async {
      throw const SocketException('unreachable');
    });
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    await tester.pump();
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.connectionProblem), findsOneWidget);
    expect(find.text(messages.noInternetConnection), findsNothing);
    expect(find.text(messages.openSettings), findsOneWidget);
    expect(_titleText(tester), 'A title');
  });

  testWidgets('Parse network failures show offline guidance after disconnect',
      (tester) async {
    final request = Completer<void>();
    await _pumpForm(tester, sender: (_, __, ___, ____) => request.future);
    await _fillForm(tester);
    await _submit(tester);
    online = false;
    request.completeError(const BugReportException(ParseError.otherCause));
    await tester.pump();
    await tester.pump();
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.noInternetConnection), findsOneWidget);
    expect(find.text(messages.submissionFailed), findsNothing);
    expect(_titleText(tester), 'A title');
  });

  testWidgets('settings failures stay visible above the report dialog',
      (tester) async {
    online = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settings, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    await _pumpForm(tester);
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump(const Duration(milliseconds: 350));
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    await tester.tap(find.text(messages.openSettings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text(messages.networkSettingsFailed), findsOneWidget);
    await tester.tap(find.text(messages.ok));
    await tester.pumpAndSettle();
    expect(find.text(messages.noInternetConnection), findsOneWidget);
    expect(_titleText(tester), 'A title');
  });

  testWidgets('reconnection closes the offline dialog without resubmitting',
      (tester) async {
    online = false;
    var submissions = 0;
    await _pumpForm(tester, sender: (_, __, ___, ____) async => submissions++);
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.noInternetConnection), findsOneWidget);

    online = true;
    await NetworkStatusMonitor.instance.refresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text(messages.noInternetConnection), findsNothing);
    expect(_titleText(tester), 'A title');
    expect(submissions, 0);
  });

  testWidgets('server errors are not mislabeled when connectivity drops',
      (tester) async {
    final request = Completer<void>();
    await _pumpForm(tester, sender: (_, __, ___, ____) => request.future);
    await _fillForm(tester);
    await _submit(tester);
    online = false;
    request.completeError(const BugReportException(119));
    await tester.pump();
    await tester.pump();
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.submissionFailed), findsOneWidget);
    expect(find.text(messages.noInternetConnection), findsNothing);
    expect(_titleText(tester), 'A title');
  });

  testWidgets('offline report guidance remains accessible with large iOS text',
      (tester) async {
    final semantics = tester.ensureSemantics();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    online = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    try {
      await _pumpForm(tester, textScale: 3);
      await _fillForm(tester);
      await _submit(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      final context = tester.element(find.byType(BugReportPage));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noInternetConnection), findsOneWidget);
      expect(find.text(messages.networkSettingsIosHint), findsOneWidget);
      final settingsButton = find.text(messages.openSettings);
      await Scrollable.ensureVisible(tester.element(settingsButton),
          alignment: 0.5);
      await tester.pump();
      expect(settingsButton.hitTestable(), findsOneWidget);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      semantics.dispose();
    }
  });

  testWidgets('can scroll to validation and submit with the keyboard open',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(640, 360);
    tester.view.viewInsets = const FakeViewPadding(bottom: 120);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await _pumpForm(tester, textScale: 2);
    await _submit(tester);
    await tester.pump();
    expect(tester.takeException(), isNull);
    final context = tester.element(find.byType(BugReportPage));
    final titleError = find.text(AppLocalizations.of(context)!.enterTitle);
    await tester.ensureVisible(titleError);
    await tester.pump();
    expect(titleError.hitTestable(), findsOneWidget);
    expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .focusNode
            .hasFocus,
        isTrue);
  });

  test('rejects attachments without a local path', () async {
    final file = PlatformFile(name: 'report.png', size: 1);
    await expectLater(
      sendBugReport('title', 'description', 'Android', file),
      throwsFormatException,
    );
  });
}

Future<void> _pumpForm(WidgetTester tester,
    {BugReportSender? sender, double textScale = 1}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: sender == null
          ? const BugReportPage()
          : BugReportPage(sender: sender),
    ),
  );
  await tester.pump();
}

Future<void> _fillForm(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(TextFormField).at(0));
  await tester.pump();
  await tester.enterText(find.byType(TextFormField).at(0), 'A title');
  await tester.ensureVisible(find.byType(TextFormField).at(1));
  await tester.pump();
  await tester.enterText(find.byType(TextFormField).at(1), 'A description');
  await tester.pumpAndSettle();
  final dropdown = find.byType(DropdownButtonFormField<String>);
  await Scrollable.ensureVisible(tester.element(dropdown), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Android').last);
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  final context = tester.element(find.byType(BugReportPage));
  final submit = find.text(AppLocalizations.of(context)!.submit);
  await tester.ensureVisible(submit);
  await tester.pump();
  await tester.tap(submit);
  await tester.pump();
}

String _titleText(WidgetTester tester) => tester
    .widget<EditableText>(find.byType(EditableText).first)
    .controller
    .text;
