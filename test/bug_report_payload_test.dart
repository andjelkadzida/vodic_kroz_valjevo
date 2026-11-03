import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'package:vodic_kroz_valjevo/helper/bug_report_device_info.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/pages/bug_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final client = _RecordingParseClient();
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');

  setUpAll(() async {
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
    client.requests.clear();
    client.payloads.clear();
    client.uploads.clear();
    client.statusCode = 201;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivity, (_) async => ['wifi']);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivity, null);
  });

  test('saves the requested fields in the Back4App BugReport class', () async {
    await sendBugReport(
      'Crash',
      'Steps to reproduce',
      'Android',
      null,
      deviceModel: ' Pixel 9 ',
      operatingSystemVersion: ' 15 ',
    );

    expect(
        client.requests.single.pathSegments,
        containsAllInOrder([
          'classes',
          'BugReport',
        ]));
    expect(client.payloads.single, {
      'title': 'Crash',
      'description': 'Steps to reproduce',
      'operatingSystem': 'Android',
      'deviceModel': 'Pixel 9',
      'operatingSystemVersion': '15',
    });
  });

  test('rejects blank device details before contacting Back4App', () async {
    for (final values in [
      ['', '15'],
      ['Pixel 9', '  '],
    ]) {
      await expectLater(
        sendBugReport(
          'Crash',
          'Steps to reproduce',
          'Android',
          null,
          deviceModel: values[0],
          operatingSystemVersion: values[1],
        ),
        throwsArgumentError,
      );
    }
    expect(client.requests, isEmpty);
  });

  test('omits unavailable device details from the Back4App payload', () async {
    final cases = <Map<String, String?>>[
      {'deviceModel': null, 'operatingSystemVersion': null},
      {'deviceModel': 'Pixel 9', 'operatingSystemVersion': null},
      {'deviceModel': null, 'operatingSystemVersion': '15'},
    ];
    for (final values in cases) {
      await sendBugReport(
        'Crash',
        'Steps to reproduce',
        'Android',
        null,
        deviceModel: values['deviceModel'],
        operatingSystemVersion: values['operatingSystemVersion'],
      );
      final payload = client.payloads.last;
      for (final entry in values.entries) {
        if (entry.value == null) {
          expect(payload.containsKey(entry.key), isFalse);
        } else {
          expect(payload[entry.key], entry.value);
        }
      }
    }
  });

  test('omits the operating system when it cannot be detected', () async {
    await sendBugReport(
      'Crash',
      'Steps to reproduce',
      null,
      null,
      deviceModel: 'Pixel 9',
      operatingSystemVersion: '15',
    );
    expect(client.payloads.single.containsKey('operatingSystem'), isFalse);
    expect(client.payloads.single['deviceModel'], 'Pixel 9');
  });

  test('retains the attachment alongside both device fields', () async {
    final directory = await Directory.systemTemp.createTemp('bug-report-test-');
    final file = File('${directory.path}${Platform.pathSeparator}report.txt');
    await file.writeAsBytes([1, 2, 3]);
    addTearDown(() async {
      await file.delete();
      await directory.delete();
    });

    await sendBugReport(
      'Crash',
      'Steps to reproduce',
      'Android',
      PlatformFile(name: 'report.txt', path: file.path, size: 3),
      deviceModel: 'Pixel 9',
      operatingSystemVersion: '15',
    );

    expect(client.uploads.single, [1, 2, 3]);
    expect(client.payloads.single['deviceModel'], 'Pixel 9');
    expect(client.payloads.single['operatingSystemVersion'], '15');
    expect(client.payloads.single['file'], {
      '__type': 'File',
      'name': 'report.txt',
      'url': 'https://example.test/files/report.txt',
    });
  });

  test('surfaces Back4App failures', () async {
    client.statusCode = 403;
    await expectLater(
      sendBugReport(
        'Crash',
        'Steps to reproduce',
        'Android',
        null,
        deviceModel: 'Pixel 9',
        operatingSystemVersion: '15',
      ),
      throwsA(
        isA<BugReportException>().having((error) => error.code, 'code', 119),
      ),
    );
  });

  testWidgets('submits the detected values from the form to Back4App',
      (tester) async {
    await _submitForm(
      tester,
      () async => const BugReportDeviceInfo(
        deviceModel: 'Detected phone',
        operatingSystemVersion: '18.1',
      ),
    );
    expect(client.payloads.single['operatingSystem'], 'Android');
    expect(client.payloads.single['deviceModel'], 'Detected phone');
    expect(client.payloads.single['operatingSystemVersion'], '18.1');
  });

  testWidgets('submits the form when device details are unavailable',
      (tester) async {
    await _submitForm(
      tester,
      () async => throw PlatformException(code: 'unavailable'),
    );
    expect(client.payloads.single.containsKey('deviceModel'), isFalse);
    expect(
        client.payloads.single.containsKey('operatingSystemVersion'), isFalse);
  });

  testWidgets('submits the form when the operating system is unavailable',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await _submitForm(
        tester,
        () async => const BugReportDeviceInfo(
          deviceModel: 'Detected device',
          operatingSystemVersion: '18.1',
        ),
      );
      expect(client.payloads.single.containsKey('operatingSystem'), isFalse);
      expect(client.payloads.single['deviceModel'], 'Detected device');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Future<void> _submitForm(
    WidgetTester tester, BugReportDeviceInfoLoader deviceInfoLoader) async {
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BugReportPage(deviceInfoLoader: deviceInfoLoader),
  ));
  await tester.pump();

  await tester.enterText(find.byType(TextFormField).at(0), 'Crash');
  await tester.enterText(find.byType(TextFormField).at(1), 'Steps');
  await tester.pumpAndSettle();

  final context = tester.element(find.byType(BugReportPage));
  final submit = find.text(AppLocalizations.of(context)!.submit);
  await tester.ensureVisible(submit);
  await tester.pump();
  await tester.tap(submit);
  await tester.pump();
  await tester.pump();
  expect(
      find.text(AppLocalizations.of(context)!.bugReportSent), findsOneWidget);
}

class _RecordingParseClient extends ParseClient {
  final requests = <Uri>[];
  final payloads = <Map<String, dynamic>>[];
  final uploads = <List<int>>[];
  int statusCode = 201;

  @override
  Future<ParseNetworkResponse> post(
    String path, {
    String? data,
    ParseNetworkOptions? options,
  }) async {
    requests.add(Uri.parse(path));
    payloads.add(jsonDecode(data!) as Map<String, dynamic>);
    return ParseNetworkResponse(
      statusCode: statusCode,
      data: statusCode == 201
          ? jsonEncode({
              'objectId': 'report1',
              'createdAt': '2024-01-01T00:00:00.000Z',
            })
          : jsonEncode({'code': 119, 'error': 'permission denied'}),
    );
  }

  @override
  Future<ParseNetworkResponse> postBytes(
    String path, {
    Stream<List<int>>? data,
    ParseNetworkOptions? options,
    ProgressCallback? onSendProgress,
    dynamic cancelToken,
  }) async {
    uploads.add(await data!.expand((bytes) => bytes).toList());
    return ParseNetworkResponse(
      statusCode: 201,
      data: jsonEncode({
        'name': 'report.txt',
        'url': 'https://example.test/files/report.txt',
      }),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
