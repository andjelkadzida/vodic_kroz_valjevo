import 'dart:async';
import 'dart:io';
import 'dart:ui' show SemanticsAction;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'
    show ParseError;
import 'package:vodic_kroz_valjevo/helper/bug_report_device_info.dart';
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
    await _pumpForm(tester, sender: (title, description, os, file,
        {required deviceModel, required operatingSystemVersion}) {
      submissions++;
      expect(title, 'A title');
      expect(description, 'A description');
      expect(os, 'Android');
      expect(deviceModel, 'Test phone');
      expect(operatingSystemVersion, '15');
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
    expect(_fieldText(tester, 2), 'Android');
    expect(_fieldText(tester, 3), 'Test phone');
    expect(_fieldText(tester, 4), '15');
  });

  testWidgets('detected device details are read-only and accessible',
      (tester) async {
    final semantics = tester.ensureSemantics();
    String? sentModel;
    String? sentVersion;
    try {
      await _pumpForm(tester, sender: (_, __, ___, ____,
          {required deviceModel, required operatingSystemVersion}) async {
        sentModel = deviceModel;
        sentVersion = operatingSystemVersion;
      });
      final context = tester.element(find.byType(BugReportPage));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.deviceModel), findsOneWidget);
      expect(find.text(messages.osVersion), findsOneWidget);
      for (final entry in {
        2: messages.operatingSystem,
        3: messages.deviceModel,
        4: messages.osVersion,
      }.entries) {
        final field = find.byType(TextFormField).at(entry.key);
        final input = find.descendant(
          of: field,
          matching: find.byType(TextField),
        );
        expect(tester.widget<TextField>(input).readOnly, isTrue);
        final node = tester.getSemantics(field);
        expect(node.label, contains(entry.value));
        expect(node.getSemanticsData().flagsCollection.isReadOnly, isTrue);
        await tester.ensureVisible(field);
        await tester.pump();
        await tester.tap(field);
        await tester.pump();
        expect(tester.testTextInput.isVisible, isFalse);
      }
      await _fillForm(tester);
      await _submit(tester);
      await tester.pump();
      expect(sentModel, 'Test phone');
      expect(sentVersion, '15');
      expect(_fieldText(tester, 2), 'Android');
      expect(_fieldText(tester, 3), 'Test phone');
      expect(_fieldText(tester, 4), '15');
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    } finally {
      semantics.dispose();
    }
  });

  for (final entry in <TargetPlatform, String?>{
    TargetPlatform.android: 'Android',
    TargetPlatform.iOS: 'iOS',
    TargetPlatform.windows: null,
  }.entries) {
    testWidgets('detects a read-only operating system on ${entry.key}',
        (tester) async {
      debugDefaultTargetPlatformOverride = entry.key;
      try {
        String? sentSystem;
        var submissions = 0;
        await _pumpForm(
          tester,
          sender: (_, __, os, ____,
              {required deviceModel, required operatingSystemVersion}) async {
            submissions++;
            sentSystem = os;
          },
        );
        final context = tester.element(find.byType(BugReportPage));
        final messages = AppLocalizations.of(context)!;
        expect(find.byType(DropdownButtonFormField<String>), findsNothing);
        final field = find.byType(TextFormField).at(2);
        final input =
            find.descendant(of: field, matching: find.byType(TextField));
        expect(tester.widget<TextField>(input).readOnly, isTrue);
        expect(_fieldText(tester, 2), entry.value ?? '');
        if (entry.value == null) {
          expect(find.text(messages.deviceInfoUnavailable), findsOneWidget);
          expect(find.text(messages.deviceInfoNotAvailable), findsOneWidget);
        }

        await _fillForm(tester);
        await _submit(tester);
        await tester.pump();
        expect(submissions, 1);
        expect(sentSystem, entry.value);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('selected attachments can be removed before submitting',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final file = PlatformFile(name: 'report.txt', size: 3, path: 'report.txt');
    PlatformFile? sentFile;
    var submissions = 0;
    try {
      await _pumpForm(
        tester,
        filePicker: () async => FilePickerResult([file]),
        sender: (_, __, ___, file,
            {required deviceModel, required operatingSystemVersion}) async {
          submissions++;
          sentFile = file;
        },
      );
      final context = tester.element(find.byType(BugReportPage));
      final messages = AppLocalizations.of(context)!;
      final upload = find.text(messages.uploadFile);
      await tester.ensureVisible(upload);
      await tester.pump();
      final uploadButton =
          find.ancestor(of: upload, matching: find.byType(OutlinedButton));
      final uploadNode = tester.getSemantics(uploadButton);
      expect(uploadNode.label, contains(messages.fileUploadLabel));
      expect(
          uploadNode.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      await tester.tap(upload);
      await tester.pump();
      expect(find.text('report.txt'), findsOneWidget);

      final remove = find.text(messages.removeAttachment);
      await tester.ensureVisible(remove);
      await tester.pump();
      expect(remove.hitTestable(), findsOneWidget);
      expect(tester.getSemantics(remove).label,
          contains(messages.removeAttachment));
      await tester.tap(remove);
      await tester.pump();
      expect(find.text(messages.noFileSelected), findsOneWidget);
      expect(find.text('report.txt'), findsNothing);
      await _fillForm(tester);
      await _submit(tester);
      await tester.pump();
      expect(submissions, 1);
      expect(sentFile, isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('selected attachment is sent and cleared on success',
      (tester) async {
    final file = PlatformFile(name: 'report.txt', size: 3, path: 'report.txt');
    PlatformFile? sentFile;
    await _pumpForm(
      tester,
      filePicker: () async => FilePickerResult([file]),
      sender: (_, __, ___, file,
          {required deviceModel, required operatingSystemVersion}) async {
        sentFile = file;
      },
    );
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    final upload = find.text(messages.uploadFile);
    await tester.ensureVisible(upload);
    await tester.pump();
    await tester.tap(upload);
    await tester.pump();
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    expect(sentFile, same(file));
    expect(find.text('report.txt'), findsNothing);
    expect(find.text(messages.noFileSelected), findsOneWidget);
  });

  testWidgets('attachment survives picker cancellation and failed submission',
      (tester) async {
    final file = PlatformFile(name: 'report.txt', size: 3, path: 'report.txt');
    var pickerCalls = 0;
    await _pumpForm(
      tester,
      filePicker: () async =>
          pickerCalls++ == 0 ? FilePickerResult([file]) : null,
      sender: (_, __, ___, ____,
          {required deviceModel, required operatingSystemVersion}) async {
        throw StateError('failed');
      },
    );
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    final upload = find.text(messages.uploadFile);
    await tester.ensureVisible(upload);
    await tester.pump();
    await tester.tap(upload);
    await tester.pump();
    await tester.tap(upload);
    await tester.pump();
    expect(find.text('report.txt'), findsOneWidget);
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    expect(find.text('report.txt'), findsOneWidget);
    expect(find.text(messages.removeAttachment), findsOneWidget);
    expect(find.text(messages.submissionFailed), findsOneWidget);
  });

  testWidgets('submits without device details when detection fails',
      (tester) async {
    var submissions = 0;
    await _pumpForm(
      tester,
      deviceInfoLoader: () async =>
          throw PlatformException(code: 'unavailable'),
      sender: (_, __, ___, ____,
          {required deviceModel, required operatingSystemVersion}) async {
        submissions++;
        expect(deviceModel, isNull);
        expect(operatingSystemVersion, isNull);
      },
    );
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.deviceInfoUnavailable), findsOneWidget);
    expect(find.text(messages.deviceInfoNotAvailable), findsNWidgets(2));
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    expect(submissions, 1);
  });

  testWidgets('submits detected values and omits unavailable details',
      (tester) async {
    var submissions = 0;
    await _pumpForm(
      tester,
      deviceInfoLoader: () async => const BugReportDeviceInfo(
        deviceModel: 'Detected phone',
        operatingSystemVersion: ' ',
      ),
      sender: (_, __, ___, ____,
          {required deviceModel, required operatingSystemVersion}) async {
        submissions++;
        expect(deviceModel, 'Detected phone');
        expect(operatingSystemVersion, isNull);
      },
    );
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.deviceInfoUnavailable), findsOneWidget);
    expect(find.text(messages.deviceInfoNotAvailable), findsOneWidget);
    expect(_fieldText(tester, 3), 'Detected phone');
    expect(_fieldText(tester, 4), isEmpty);
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    expect(submissions, 1);
  });

  testWidgets('waits for detection before submitting', (tester) async {
    final detection = Completer<BugReportDeviceInfo>();
    var submissions = 0;
    await _pumpForm(
      tester,
      deviceInfoLoader: () => detection.future,
      sender: (_, __, ___, ____,
          {required deviceModel, required operatingSystemVersion}) async {
        submissions++;
        expect(deviceModel, 'Detected phone');
        expect(operatingSystemVersion, '18');
      },
    );
    await _fillForm(tester);
    await _submit(tester);
    expect(submissions, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    detection.complete(const BugReportDeviceInfo(
      deviceModel: 'Detected phone',
      operatingSystemVersion: '18',
    ));
    await tester.pump();
    await tester.pump();
    expect(submissions, 1);
    expect(_fieldText(tester, 3), 'Detected phone');
    expect(_fieldText(tester, 4), '18');
  });

  testWidgets('submits without details when detection times out',
      (tester) async {
    final detection = Completer<BugReportDeviceInfo>();
    var submissions = 0;
    await _pumpForm(
      tester,
      deviceInfoLoader: () => detection.future,
      sender: (_, __, ___, ____,
          {required deviceModel, required operatingSystemVersion}) async {
        submissions++;
        expect(deviceModel, isNull);
        expect(operatingSystemVersion, isNull);
      },
    );
    await _fillForm(tester);
    await _submit(tester);
    expect(submissions, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump();
    expect(submissions, 1);

    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.deviceInfoUnavailable), findsOneWidget);
    expect(find.text(messages.loading), findsNothing);
    detection.complete(const BugReportDeviceInfo(
      deviceModel: 'Late phone',
      operatingSystemVersion: '18',
    ));
    await tester.pump();
    expect(_fieldText(tester, 3), isEmpty);
    expect(_fieldText(tester, 4), isEmpty);
  });

  testWidgets('cancels a pending submission when the form is disposed',
      (tester) async {
    final detection = Completer<BugReportDeviceInfo>();
    var submissions = 0;
    await _pumpForm(
      tester,
      deviceInfoLoader: () => detection.future,
      sender: (_, __, ___, ____,
          {required deviceModel, required operatingSystemVersion}) async {
        submissions++;
      },
    );
    await _fillForm(tester);
    await _submit(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    detection.complete(const BugReportDeviceInfo(
      deviceModel: 'Test phone',
      operatingSystemVersion: '15',
    ));
    await tester.pump();
    expect(submissions, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validates existing required fields while detection is pending',
      (tester) async {
    final detection = Completer<BugReportDeviceInfo>();
    await _pumpForm(tester, deviceInfoLoader: () => detection.future);
    await _submit(tester);
    final context = tester.element(find.byType(BugReportPage));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.enterTitle), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    detection.complete(const BugReportDeviceInfo(
      deviceModel: 'Test phone',
      operatingSystemVersion: '15',
    ));
    await tester.pump();
  });

  testWidgets('keeps form data and reports a failed submission',
      (tester) async {
    await _pumpForm(tester, sender: (_, __, ___, ____,
        {required deviceModel, required operatingSystemVersion}) async {
      throw StateError('failed');
    });
    await _fillForm(tester);
    await _submit(tester);
    await tester.pump();
    await tester.pump();
    expect(_titleText(tester), 'A title');
    expect(_fieldText(tester, 3), 'Test phone');
    expect(_fieldText(tester, 4), '15');
    final context = tester.element(find.byType(BugReportPage));
    expect(find.text(AppLocalizations.of(context)!.submissionFailed),
        findsOneWidget);
  });

  testWidgets('does not send when connectivity is unavailable', (tester) async {
    online = false;
    var submissions = 0;
    await _pumpForm(tester,
        sender: (_, __, ___, ____,
                {required deviceModel,
                required operatingSystemVersion}) async =>
            submissions++);
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
    await _pumpForm(tester, sender: (_, __, ___, ____,
        {required deviceModel, required operatingSystemVersion}) {
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
    await _pumpForm(tester, sender: (_, __, ___, ____,
        {required deviceModel, required operatingSystemVersion}) async {
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
    await _pumpForm(tester,
        sender: (_, __, ___, ____,
                {required deviceModel, required operatingSystemVersion}) =>
            request.future);
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
    await _pumpForm(tester,
        sender: (_, __, ___, ____,
                {required deviceModel,
                required operatingSystemVersion}) async =>
            submissions++);
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
    await _pumpForm(tester,
        sender: (_, __, ___, ____,
                {required deviceModel, required operatingSystemVersion}) =>
            request.future);
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

  const largeTextLocales = [
    Locale('en'),
    Locale('de'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
  ];
  for (final locale in largeTextLocales) {
    testWidgets(
        'read-only device details remain accessible with large text in $locale',
        (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 480);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      try {
        await _pumpForm(
          tester,
          locale: locale,
          textScale: 3,
          deviceInfoLoader: () async =>
              throw PlatformException(code: 'missing'),
          filePicker: () async => FilePickerResult([
            PlatformFile(
              name: 'a-comprehensive-screenshot-of-the-issue.png',
              size: 1,
              path: 'report.png',
            ),
          ]),
        );
        await _submit(tester);
        final context = tester.element(find.byType(BugReportPage));
        final messages = AppLocalizations.of(context)!;
        for (final message in [
          messages.bugReportIntro,
          messages.deviceInfoUnavailable,
          messages.enterTitle,
          messages.enterDescription,
        ]) {
          final text = find.text(message);
          await tester.ensureVisible(text);
          await tester.pump();
          expect(
            tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
            isFalse,
            reason: message,
          );
        }
        for (final title in [
          messages.bugReportDetails,
          messages.bugReportDeviceDetails,
          messages.bugReportAttachment,
        ]) {
          final heading = find.text(title);
          await tester.ensureVisible(heading);
          await tester.pump();
          expect(
              tester.renderObject<RenderParagraph>(heading).didExceedMaxLines,
              isFalse);
          expect(
            tester
                .getSemantics(heading)
                .getSemanticsData()
                .flagsCollection
                .isHeader,
            isTrue,
          );
        }
        final unavailable = find.text(messages.deviceInfoNotAvailable);
        expect(unavailable, findsNWidgets(2));
        for (var index = 0; index < 2; index++) {
          final text = unavailable.at(index);
          await tester.ensureVisible(text);
          await tester.pump();
          expect(
            tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
            isFalse,
          );
        }
        for (final entry in {
          2: messages.operatingSystem,
          3: messages.deviceModel,
          4: messages.osVersion,
        }.entries) {
          final field = find.byType(TextFormField).at(entry.key);
          await tester.ensureVisible(field);
          await tester.pump();
          expect(field.hitTestable(), findsOneWidget);
          final node = tester.getSemantics(field);
          expect(node.label, contains(entry.value));
          expect(node.getSemanticsData().flagsCollection.isReadOnly, isTrue);
          if (entry.key != 2) {
            final data = node.getSemanticsData();
            expect(
              '${data.label} ${data.value} ${data.hint}',
              contains(messages.deviceInfoNotAvailable),
            );
          }
        }
        final upload = find.text(messages.uploadFile);
        await tester.ensureVisible(upload);
        await tester.pump();
        expect(tester.renderObject<RenderParagraph>(upload).didExceedMaxLines,
            isFalse);
        expect(upload.hitTestable(), findsOneWidget);
        await tester.tap(upload);
        await tester.pump();
        final filename = find.text('a-comprehensive-screenshot-of-the-issue.png');
        await tester.ensureVisible(filename);
        await tester.pump();
        expect(tester.renderObject<RenderParagraph>(filename).didExceedMaxLines,
            isFalse);
        final remove = find.text(messages.removeAttachment);
        await tester.ensureVisible(remove);
        await tester.pump();
        expect(tester.renderObject<RenderParagraph>(remove).didExceedMaxLines,
            isFalse);
        expect(remove.hitTestable(), findsOneWidget);
        final removeButton =
            find.ancestor(of: remove, matching: find.byType(TextButton));
        expect(tester.getSize(removeButton).shortestSide, greaterThanOrEqualTo(48));
        await tester.tap(remove);
        await tester.pump();
        expect(find.text(messages.noFileSelected), findsOneWidget);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }

  testWidgets('long detected values wrap at large text sizes', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const model = 'Example manufacturer flagship phone with a long model name';
    const version = 'Version 18.1 with a long security patch description';
    try {
      await _pumpForm(
        tester,
        textScale: 3,
        deviceInfoLoader: () async => const BugReportDeviceInfo(
          deviceModel: model,
          operatingSystemVersion: version,
        ),
      );
      for (final entry in {3: model, 4: version}.entries) {
        final field = find.byType(TextFormField).at(entry.key);
        await tester.ensureVisible(field);
        await tester.pump();
        final editable = find.descendant(
          of: field,
          matching: find.byType(EditableText),
        );
        final render = tester.state<EditableTextState>(editable).renderEditable;
        expect(
            render.size.height, greaterThan(render.preferredLineHeight * 1.5));
        expect(tester.getSemantics(field).value, contains(entry.value));
      }
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  test('rejects attachments without a local path', () async {
    final file = PlatformFile(name: 'report.png', size: 1);
    await expectLater(
      sendBugReport(
        'title',
        'description',
        'Android',
        file,
        deviceModel: 'Test phone',
        operatingSystemVersion: '15',
      ),
      throwsFormatException,
    );
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  BugReportSender? sender,
  BugReportDeviceInfoLoader? deviceInfoLoader,
  BugReportFilePicker? filePicker,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: BugReportPage(
        sender: sender ?? sendBugReport,
        deviceInfoLoader: deviceInfoLoader ??
            () async => const BugReportDeviceInfo(
                  deviceModel: 'Test phone',
                  operatingSystemVersion: '15',
                ),
        filePicker: filePicker ?? () => FilePicker.platform.pickFiles(),
      ),
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

String _fieldText(WidgetTester tester, int index) => tester
    .widget<TextFormField>(find.byType(TextFormField).at(index))
    .controller!
    .text;
