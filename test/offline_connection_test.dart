import 'dart:async';
import 'dart:io';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_service.dart';
import 'package:vodic_kroz_valjevo/helper/connection_problem_view.dart';
import 'package:vodic_kroz_valjevo/helper/images_loader_helper.dart';
import 'package:vodic_kroz_valjevo/helper/internet_connectivity.dart';
import 'package:vodic_kroz_valjevo/helper/remote_data_builder.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/main.dart';

void main() {
  const settingsChannel = MethodChannel('com.spencerccf.app_settings/methods');
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const events = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
  final settingsCalls = <MethodCall>[];

  setUp(() {
    settingsCalls.clear();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(settingsChannel, (call) async {
      settingsCalls.add(call);
      return null;
    });
    messenger.setMockMethodCallHandler(connectivity, (_) async => ['none']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(settingsChannel, null);
    messenger.setMockMethodCallHandler(connectivity, null);
    messenger.setMockMethodCallHandler(events, null);
  });

  testWidgets('a pending offline request offers settings and retries online',
      (tester) async {
    final network = _FakeNetwork(false);
    final firstRequest = Completer<String>();
    var requests = 0;
    try {
      await tester.pumpWidget(_app(
        RemoteDataBuilder<String>(
          queryKey: 'offline',
          networkStatus: network.monitor,
          load: () {
            requests++;
            return requests == 1 ? firstRequest.future : Future.value('Loaded');
          },
          onData: (data) => Text(data),
        ),
      ));
      await tester.pump();
      await tester.pump();
      final context = tester.element(find.byType(RemoteDataBuilder<String>));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noInternetConnection), findsOneWidget);
      expect(find.text(messages.errorLoadingData), findsNothing);
      expect(find.text(messages.retryConnection), findsOneWidget);
      await tester.tap(find.text(messages.openSettings));
      await tester.pump();
      expect(settingsCalls, hasLength(1));
      expect(settingsCalls.single.method, 'openSettings');
      expect((settingsCalls.single.arguments as Map)['type'], 'wireless');

      network.update(true);
      await tester.pump();
      await tester.pump();
      expect(requests, 2);
      expect(find.text('Loaded'), findsOneWidget);

      firstRequest.completeError(const SocketException('old request failed'));
      await tester.pump();
      expect(find.text('Loaded'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      await _disposeNetwork(tester, network);
    }
  });

  testWidgets(
      'offline settings and retry work with keyboard and screen readers',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var retries = 0;
    try {
      await tester.pumpWidget(_app(
        ConnectionProblemView(
          disconnected: true,
          onRetry: () => retries++,
        ),
      ));
      final context = tester.element(find.byType(ConnectionProblemView));
      final messages = AppLocalizations.of(context)!;
      final settingsButton = find.text(messages.openSettings);
      Focus.of(tester.element(settingsButton)).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(settingsCalls, hasLength(1));

      final retry = find.text(messages.retryConnection);
      final retryNode = tester.getSemantics(retry);
      tester.semantics.tap(find.semantics.byLabel(retryNode.label));
      await tester.pump();
      expect(retries, 1);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('cached data remains visible offline and is not reloaded',
      (tester) async {
    final network = _FakeNetwork(false);
    final cached = Completer<String>();
    var requests = 0;
    try {
      await tester.pumpWidget(_app(
        RemoteDataBuilder<String>(
          queryKey: 'cached',
          networkStatus: network.monitor,
          load: () {
            requests++;
            return cached.future;
          },
          onData: (data) => Text(data),
        ),
      ));
      await tester.pump();
      await tester.pump();
      final context = tester.element(find.byType(RemoteDataBuilder<String>));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noInternetConnection), findsOneWidget);
      cached.complete('Cached data');
      await tester.pump();
      await tester.pump();
      expect(find.text('Cached data'), findsOneWidget);
      expect(find.text(messages.noInternetConnection), findsNothing);
      network.update(true);
      await tester.pump();
      expect(requests, 1);
    } finally {
      await _disposeNetwork(tester, network);
    }
  });

  testWidgets('shared refresh is triggered only once when reconnecting',
      (tester) async {
    final network = _FakeNetwork(false);
    final signal = ValueNotifier<int>(0);
    final first = Completer<String>();
    final second = Completer<String>();
    var firstLoads = 0;
    var secondLoads = 0;
    var invalidations = 0;

    Widget request(Future<String> Function() load, String key) =>
        RemoteDataBuilder<String>(
          queryKey: key,
          networkStatus: network.monitor,
          refreshSignal: signal,
          onRetry: () {
            invalidations++;
            signal.value++;
          },
          load: load,
          onData: (data) => Text(data),
        );

    try {
      await tester.pumpWidget(_app(Column(
        children: [
          Expanded(
            child: request(() {
              firstLoads++;
              return firstLoads == 1 ? first.future : Future.value('First');
            }, 'first'),
          ),
          Expanded(
            child: request(() {
              secondLoads++;
              return secondLoads == 1 ? second.future : Future.value('Second');
            }, 'second'),
          ),
        ],
      )));
      await tester.pump();
      await tester.pump();
      network.update(true);
      await tester.pump();
      await tester.pump();
      expect(invalidations, 1);
      expect(firstLoads, 2);
      expect(secondLoads, 2);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      first.completeError(const SocketException('old first request'));
      second.completeError(const SocketException('old second request'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    } finally {
      await _disposeNetwork(tester, network);
      signal.dispose();
    }
  });

  for (final error in <Object>[
    const FormatException('invalid record'),
    const Back4AppDataException('forbidden', code: 119),
  ]) {
    testWidgets('a non-network error remains distinct while offline: $error',
        (tester) async {
      final network = _FakeNetwork(false);
      try {
        await tester.pumpWidget(_app(
          RemoteDataBuilder<String>(
            queryKey: error,
            networkStatus: network.monitor,
            load: () async => throw error,
            onData: (data) => Text(data),
          ),
        ));
        await tester.pump();
        await tester.pump();
        final context = tester.element(find.byType(RemoteDataBuilder<String>));
        final messages = AppLocalizations.of(context)!;
        expect(find.text(messages.errorLoadingData), findsOneWidget);
        expect(find.text(messages.noInternetConnection), findsNothing);
        expect(find.text(messages.openSettings), findsNothing);
      } finally {
        await _disposeNetwork(tester, network);
      }
    });
  }

  testWidgets('a connection failure on Wi-Fi offers guidance without guessing',
      (tester) async {
    final network = _FakeNetwork(true);
    try {
      await tester.pumpWidget(_app(
        RemoteDataBuilder<String>(
          queryKey: 'connection',
          networkStatus: network.monitor,
          load: () async => throw const SocketException('unreachable'),
          onData: (data) => Text(data),
        ),
      ));
      await tester.pump();
      await tester.pump();
      final context = tester.element(find.byType(RemoteDataBuilder<String>));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.connectionProblem), findsOneWidget);
      expect(find.text(messages.noInternetConnection), findsNothing);
      expect(find.text(messages.openSettings), findsOneWidget);
    } finally {
      await _disposeNetwork(tester, network);
    }
  });

  testWidgets('empty cached data remains a no-data state while offline',
      (tester) async {
    final network = _FakeNetwork(false);
    try {
      await tester.pumpWidget(_app(
        RemoteDataBuilder<List<String>>(
          queryKey: 'empty',
          networkStatus: network.monitor,
          load: () async => [],
          onData: (_) => const Text('unexpected'),
        ),
      ));
      await tester.pump();
      await tester.pump();
      final context =
          tester.element(find.byType(RemoteDataBuilder<List<String>>));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noDataAvailable), findsOneWidget);
      expect(find.text(messages.noInternetConnection), findsNothing);
    } finally {
      await _disposeNetwork(tester, network);
    }
  });

  testWidgets('image network failures offer settings and retry on reconnect',
      (tester) async {
    final network = _FakeNetwork(false);
    var retries = 0;
    try {
      await tester.pumpWidget(_app(
        TourImageFailure(
          error: const SocketException('offline'),
          networkStatus: network.monitor,
          onRetry: () => retries++,
        ),
      ));
      await tester.pump();
      await tester.pump();
      final context = tester.element(find.byType(TourImageFailure));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noInternetConnection), findsOneWidget);
      expect(find.text(messages.openSettings), findsOneWidget);
      network.update(true);
      await tester.pump();
      expect(retries, 1);
    } finally {
      await _disposeNetwork(tester, network);
    }
  });

  testWidgets('compact offline image settings work at large text sizes',
      (tester) async {
    final network = _FakeNetwork(false);
    final semantics = tester.ensureSemantics();
    var openedDetails = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 480);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(
        Center(
          child: SizedBox(
            width: 140,
            height: 150,
            child: Semantics(
              label: 'Open item',
              button: true,
              child: InkWell(
                onTap: () => openedDetails = true,
                child: TourImageFailure(
                  error: const SocketException('offline'),
                  compact: true,
                  networkStatus: network.monitor,
                  onRetry: () {},
                ),
              ),
            ),
          ),
        ),
        locale:
            const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
        textScale: 3,
      ));
      await tester.pump();
      await tester.pump();
      final context = tester.element(find.byType(TourImageFailure));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noInternetConnection), findsOneWidget);
      expect(find.text(messages.networkSettingsIosHint), findsOneWidget);
      final settingsButton = find.text(messages.openSettings);
      await Scrollable.ensureVisible(tester.element(settingsButton),
          alignment: 0.5);
      await tester.pump();
      expect(
        settingsButton.hitTestable(),
        findsOneWidget,
        reason: 'settings=${tester.getRect(settingsButton)}, '
            'image=${tester.getRect(find.byType(TourImageFailure))}',
      );
      await tester.tap(settingsButton);
      await tester.pump();
      expect(settingsCalls, hasLength(1));
      expect(openedDetails, isFalse);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      await _disposeNetwork(tester, network);
      semantics.dispose();
    }
  });

  testWidgets('failed settings launch is reported in the selected language',
      (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    await tester.pumpWidget(_app(
      const ConnectionProblemView(disconnected: true),
      locale: const Locale('de'),
    ));
    final context = tester.element(find.byType(ConnectionProblemView));
    final messages = AppLocalizations.of(context)!;
    await tester.tap(find.text(messages.openSettings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text(messages.networkSettingsFailed), findsOneWidget);
    expect(find.text(messages.ok), findsOneWidget);
  });

  testWidgets('settings errors after leaving the screen do not open a dialog',
      (tester) async {
    final request = Completer<Object?>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (_) => request.future);
    await tester.pumpWidget(_app(
      const ConnectionProblemView(disconnected: true),
    ));
    final context = tester.element(find.byType(ConnectionProblemView));
    final messages = AppLocalizations.of(context)!;
    await tester.tap(find.text(messages.openSettings));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    request.completeError(PlatformException(code: 'unavailable'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings failure remains visible at large iOS text',
      (tester) async {
    final semantics = tester.ensureSemantics();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    try {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 480);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(
        const ConnectionProblemView(disconnected: true),
        locale: const Locale('de'),
        textScale: 3,
      ));
      final context = tester.element(find.byType(ConnectionProblemView));
      final messages = AppLocalizations.of(context)!;
      final settingsButton = find.text(messages.openSettings);
      await tester.ensureVisible(settingsButton);
      await tester.pump();
      await tester.tap(settingsButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(
          of: dialog,
          matching: find.text(messages.networkSettingsFailed),
        ),
        findsOneWidget,
      );
      final close =
          find.descendant(of: dialog, matching: find.text(messages.ok));
      await tester.ensureVisible(close);
      await tester.pump();
      expect(close.hitTestable(), findsOneWidget);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      semantics.dispose();
    }
  });

  testWidgets('an image retry failure is reported without pretending success',
      (tester) async {
    var evicted = false;
    await tester.pumpWidget(_app(
      Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => retryImageProviders(
            context: context,
            providers: () => [_FailingEvictImageProvider()],
            onEvicted: () => evicted = true,
          ),
          child: const Text('Retry image'),
        );
      }),
    ));
    final context = tester.element(find.byType(ElevatedButton));
    final messages = AppLocalizations.of(context)!;
    await tester.tap(find.text('Retry image'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text(messages.errorLoadingData), findsOneWidget);
    expect(find.text(messages.ok), findsOneWidget);
    expect(evicted, isFalse);
  });

  testWidgets('image retry errors after leaving the screen are handled',
      (tester) async {
    final key = Completer<_PendingEvictImageProvider>();
    final provider = _PendingEvictImageProvider(key.future);
    await tester.pumpWidget(_app(
      Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => retryImageProviders(
            context: context,
            providers: () => [provider],
            onEvicted: () => fail('The failed retry must not succeed'),
          ),
          child: const Text('Retry image'),
        );
      }),
    ));
    await tester.tap(find.text('Retry image'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    key.completeError(StateError('Unable to evict the image'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('iOS guidance and actions remain accessible at large text',
      (tester) async {
    final semantics = tester.ensureSemantics();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 480);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(
        ConnectionProblemView(disconnected: true, onRetry: () {}),
        locale: const Locale('de'),
        textScale: 3,
      ));
      await tester.pump();
      final context = tester.element(find.byType(ConnectionProblemView));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.networkSettingsIosHint), findsOneWidget);
      final settings = find.text(messages.openSettings);
      await tester.ensureVisible(settings);
      await tester.pump();
      expect(settings.hitTestable(), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
      semantics.dispose();
    }
  });

  testWidgets('a startup network failure shows offline guidance',
      (tester) async {
    await tester.pumpWidget(ApplicationBootstrap(
      initialize: () async => throw const SocketException('offline'),
    ));
    await tester.pump();
    await tester.pump();
    final context = tester.element(find.byType(Scaffold));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.noInternetConnection), findsOneWidget);
    expect(find.text(messages.openSettings), findsOneWidget);
    expect(find.text(messages.errorLoadingData), findsNothing);
  });

  testWidgets('startup retries a network failure when connectivity returns',
      (tester) async {
    var connected = false;
    var attempts = 0;
    final retry = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            connectivity, (_) async => [connected ? 'wifi' : 'none']);
    await tester.pumpWidget(ApplicationBootstrap(
      initialize: () {
        attempts++;
        if (attempts == 1) {
          return Future.error(const SocketException('offline'));
        }
        return retry.future;
      },
    ));
    await tester.pump();
    await tester.pump();
    final context = tester.element(find.byType(Scaffold));
    final messages = AppLocalizations.of(context)!;
    expect(find.text(messages.noInternetConnection), findsOneWidget);

    connected = true;
    await NetworkStatusMonitor.instance.refresh();
    await tester.pump();
    expect(attempts, 2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    retry.completeError(StateError('invalid configuration'));
    await tester.pump();
    await tester.pump();
    expect(find.text(messages.errorLoadingData), findsOneWidget);
    expect(find.text(messages.noInternetConnection), findsNothing);
  });

  const locales = <_OfflineLocale>[
    _OfflineLocale(
      Locale('en'),
      'No Internet Connection!',
      'Open Settings',
      'Try again',
    ),
    _OfflineLocale(
      Locale('de'),
      'Keine Internetverbindung!',
      'Einstellungen öffnen',
      'Erneut versuchen',
    ),
    _OfflineLocale(
      Locale('sr'),
      'Nema internet konekcije!',
      'Otvorite podešavanja',
      'Pokušaj ponovo',
    ),
    _OfflineLocale(
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      'Nema internet konekcije!',
      'Otvorite podešavanja',
      'Pokušaj ponovo',
    ),
    _OfflineLocale(
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
      'Нема интернет конекције!',
      'Отворите подешавања',
      'Покушај поново',
    ),
  ];

  for (final locale in locales) {
    testWidgets('offline controls are localized for ${locale.locale}',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_app(
          ConnectionProblemView(disconnected: true, onRetry: () {}),
          locale: locale.locale,
        ));
        await tester.pump();
        expect(find.text(locale.message), findsOneWidget);
        final settingsButton = find.text(locale.settings);
        final retryButton = find.text(locale.retry);
        expect(settingsButton, findsOneWidget);
        expect(retryButton, findsOneWidget);
        final settingsNode = tester.getSemantics(settingsButton);
        final retryNode = tester.getSemantics(retryButton);
        expect(settingsNode.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue);
        expect(retryNode.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        semantics.dispose();
      }
    });
  }
}

Widget _app(Widget body,
        {Locale locale = const Locale('en'), double textScale = 1}) =>
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
      home: Scaffold(body: body),
    );

class _FakeNetwork {
  _FakeNetwork(this.connected) {
    monitor = NetworkStatusMonitor(
      checkConnection: () async => connected,
      connectionChanges: () => events.stream,
    );
  }

  bool connected;
  final StreamController<bool> events =
      StreamController<bool>.broadcast(sync: true);
  late final NetworkStatusMonitor monitor;

  void update(bool value) {
    connected = value;
    events.add(value);
  }
}

class _OfflineLocale {
  const _OfflineLocale(this.locale, this.message, this.settings, this.retry);

  final Locale locale;
  final String message;
  final String settings;
  final String retry;
}

class _FailingEvictImageProvider
    extends ImageProvider<_FailingEvictImageProvider> {
  @override
  Future<_FailingEvictImageProvider> obtainKey(
          ImageConfiguration configuration) =>
      Future.error(StateError('Unable to evict the image'));
}

class _PendingEvictImageProvider
    extends ImageProvider<_PendingEvictImageProvider> {
  const _PendingEvictImageProvider(this.key);

  final Future<_PendingEvictImageProvider> key;

  @override
  Future<_PendingEvictImageProvider> obtainKey(
          ImageConfiguration configuration) =>
      key;
}

Future<void> _disposeNetwork(WidgetTester tester, _FakeNetwork network) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  network.monitor.dispose();
  await network.events.close();
}
