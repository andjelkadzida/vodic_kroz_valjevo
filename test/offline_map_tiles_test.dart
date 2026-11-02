import 'dart:async';
import 'dart:io';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import '../lib/helper/internet_connectivity.dart';
import '../lib/l10n/app_localizations.dart';
import '../lib/maps_navigation/map_builder.dart';

import 'support/network_image_test_support.dart';

void main() {
  const layouts = [
    _MapLayout('normal text', Size(390, 844), 1, true),
    _MapLayout('landscape', Size(640, 360), 2, true),
    _MapLayout('tablet large text', Size(800, 1280), 3, true),
    _MapLayout('large text', Size(320, 480), 3, false),
  ];
  for (final layout in layouts) {
    testWidgets('map tile connection guidance works with ${layout.name}',
        (tester) async {
      const connectivity =
          MethodChannel('dev.fluttercommunity.plus/connectivity');
      const events =
          MethodChannel('dev.fluttercommunity.plus/connectivity_status');
      const settings = MethodChannel('com.spencerccf.app_settings/methods');
      const urlLauncher = MethodChannel('plugins.flutter.io/url_launcher');
      final settingsCalls = <MethodCall>[];
      final openedUrls = <String>[];
      final provider = _ControlledTileProvider();
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(connectivity, (_) async => ['wifi']);
      messenger.setMockMethodCallHandler(events, (_) async => null);
      messenger.setMockMethodCallHandler(settings, (call) async {
        settingsCalls.add(call);
        return null;
      });
      messenger.setMockMethodCallHandler(urlLauncher, (call) async {
        if (call.method == 'launch') {
          openedUrls.add((call.arguments as Map)['url'] as String);
        }
        return true;
      });
      final semantics = tester.ensureSemantics();
      try {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = layout.size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(layout.textScale),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: MapPage(tileProvider: provider),
          ),
        );
        final context = tester.element(find.byType(MapPage));
        final messages = AppLocalizations.of(context)!;
        await waitForWidgetCondition(
          tester,
          () => find.text(messages.connectionProblem).evaluate().isNotEmpty,
        );
        expect(find.text(messages.noInternetConnection), findsNothing);
        final credits = find.text('© OpenStreetMap');
        MapCamera? cameraBeforeRetry;
        if (layout.mapVisibleDuringFailure) {
          expect(find.byType(FlutterMap), findsOneWidget);
          expect(credits.hitTestable(), findsOneWidget);
          _expectAttributionFullyVisible(tester, credits);
          final creditLink = find.ancestor(
            of: credits,
            matching: find.byType(InkWell),
          );
          final creditNode = tester.getSemantics(creditLink);
          expect(creditNode.label, contains('OpenStreetMap'));
          expect(creditNode.getSemanticsData().hasAction(SemanticsAction.tap),
              isTrue);
          await tester.tap(credits);
          await tester.pump();
          expect(openedUrls, ['https://www.openstreetmap.org/copyright']);
          final controller =
              tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
          final zoom = find.byWidgetPredicate(
            (widget) =>
                widget is IconButton && widget.tooltip == messages.zoomIn,
          );
          await waitForWidgetCondition(
            tester,
            () => tester.widget<IconButton>(zoom).onPressed != null,
          );
          final originalZoom = controller.camera.zoom;
          await tester.tap(zoom);
          await tester.pump();
          expect(controller.camera.zoom, greaterThan(originalZoom));
          cameraBeforeRetry = controller.camera;
        } else {
          expect(find.byType(FlutterMap), findsNothing);
          expect(credits, findsNothing);
        }
        final settingsButton = find.text(messages.openSettings);
        await Scrollable.ensureVisible(tester.element(settingsButton),
            alignment: 0.5);
        await tester.pump();
        expect(settingsButton.hitTestable(), findsOneWidget);
        await tester.tap(settingsButton);
        await tester.pump();
        expect(settingsCalls.single.method, 'openSettings');
        if (layout.mapVisibleDuringFailure) {
          expect(credits.hitTestable(), findsOneWidget);
        }
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        provider.offline = false;
        final requestsBeforeRetry = provider.requests;
        final retry = find.text(messages.retryConnection);
        await Scrollable.ensureVisible(tester.element(retry), alignment: 0.5);
        await tester.pump();
        expect(retry.hitTestable(), findsOneWidget);
        await tester.tap(retry);
        await waitForWidgetCondition(
          tester,
          () =>
              provider.requests > requestsBeforeRetry &&
              find.text(messages.connectionProblem).evaluate().isEmpty &&
              find
                  .byWidgetPredicate(
                    (widget) => widget is RawImage && widget.image != null,
                  )
                  .evaluate()
                  .isNotEmpty,
        );
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(credits.hitTestable(), findsOneWidget);
        _expectAttributionFullyVisible(tester, credits);
        if (cameraBeforeRetry != null) {
          final camera = tester
              .widget<FlutterMap>(find.byType(FlutterMap))
              .mapController!
              .camera;
          expect(camera.zoom, cameraBeforeRetry.zoom);
          expect(camera.center, cameraBeforeRetry.center);
        }
        expect(provider.disposeCount, 0);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(provider.disposeCount, 1);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        semantics.dispose();
        messenger.setMockMethodCallHandler(connectivity, null);
        messenger.setMockMethodCallHandler(events, null);
        messenger.setMockMethodCallHandler(settings, null);
        messenger.setMockMethodCallHandler(urlLauncher, null);
      }
    });
  }

  testWidgets('the real network tile provider reports client failures',
      (tester) async {
    const connectivity =
        MethodChannel('dev.fluttercommunity.plus/connectivity');
    const events =
        MethodChannel('dev.fluttercommunity.plus/connectivity_status');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, (_) async => ['wifi']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
    final client = _ControlledHttpClient();
    final provider = _ControlledNetworkTileProvider('retry', client);
    try {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapPage(tileProvider: provider),
        ),
      );
      final context = tester.element(find.byType(MapPage));
      final messages = AppLocalizations.of(context)!;
      await waitForWidgetCondition(
        tester,
        () => find.text(messages.connectionProblem).evaluate().isNotEmpty,
      );
      expect(find.text(messages.openSettings), findsOneWidget);
      expect(find.text(messages.noInternetConnection), findsNothing);
      final requestsBeforeRetry = client.requests;
      client.offline = false;
      final retry = find.text(messages.retryConnection);
      await tester.ensureVisible(retry);
      await tester.pump();
      await tester.tap(retry);
      await waitForWidgetCondition(
        tester,
        () =>
            client.requests > requestsBeforeRetry &&
            find.text(messages.connectionProblem).evaluate().isEmpty &&
            find
                .byWidgetPredicate(
                  (widget) => widget is RawImage && widget.image != null,
                )
                .evaluate()
                .isNotEmpty,
        debug: () => 'requests=$requestsBeforeRetry/${client.requests}, '
            'notice=${find.text(messages.connectionProblem).evaluate().length}, '
            'images=${find.byType(RawImage).evaluate().length}',
      );
      expect(client.closeCount, 0);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      messenger.setMockMethodCallHandler(connectivity, null);
      messenger.setMockMethodCallHandler(events, null);
    }
    expect(client.closeCount, 1);
  });

  testWidgets('the real tile provider reloads when a connection returns',
      (tester) async {
    const connectivity =
        MethodChannel('dev.fluttercommunity.plus/connectivity');
    const events =
        MethodChannel('dev.fluttercommunity.plus/connectivity_status');
    var connected = true;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        connectivity, (_) async => [connected ? 'wifi' : 'none']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
    final client = _ControlledHttpClient();
    final provider = _ControlledNetworkTileProvider('reconnect', client);
    try {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapPage(tileProvider: provider),
        ),
      );
      final context = tester.element(find.byType(MapPage));
      final messages = AppLocalizations.of(context)!;
      await waitForWidgetCondition(
        tester,
        () => find.text(messages.connectionProblem).evaluate().isNotEmpty,
      );
      final requestsBeforeReconnect = client.requests;
      connected = false;
      await NetworkStatusMonitor.instance.refresh();
      await tester.pump();
      expect(find.text(messages.noInternetConnection), findsOneWidget);

      client.offline = false;
      connected = true;
      await NetworkStatusMonitor.instance.refresh();
      await waitForWidgetCondition(
        tester,
        () =>
            client.requests > requestsBeforeReconnect &&
            find.text(messages.connectionProblem).evaluate().isEmpty &&
            find
                .byWidgetPredicate(
                  (widget) => widget is RawImage && widget.image != null,
                )
                .evaluate()
                .isNotEmpty,
        debug: () => 'requests=$requestsBeforeReconnect/${client.requests}, '
            'notice=${find.text(messages.connectionProblem).evaluate().length}',
      );
      expect(find.text(messages.noInternetConnection), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      messenger.setMockMethodCallHandler(connectivity, null);
      messenger.setMockMethodCallHandler(events, null);
    }
    expect(client.closeCount, 1);
  });

  testWidgets(
      'a reconnect during tile eviction finishes without duplicate retries',
      (tester) async {
    const connectivity =
        MethodChannel('dev.fluttercommunity.plus/connectivity');
    const events =
        MethodChannel('dev.fluttercommunity.plus/connectivity_status');
    var connected = true;
    final gate = Completer<void>();
    final provider = _ControlledTileProvider()..evictionGate = gate.future;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        connectivity, (_) async => [connected ? 'wifi' : 'none']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
    try {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapPage(tileProvider: provider),
        ),
      );
      final context = tester.element(find.byType(MapPage));
      final messages = AppLocalizations.of(context)!;
      await waitForWidgetCondition(
        tester,
        () => find.text(messages.connectionProblem).evaluate().isNotEmpty,
      );
      final retry = find.text(messages.retryConnection);
      await tester.ensureVisible(retry);
      await tester.pump();
      await tester.tap(retry);
      await tester.pump();
      await tester.pump();
      expect(provider.evictions, greaterThan(0));
      final evictionsBeforeReconnect = provider.evictions;

      connected = false;
      await NetworkStatusMonitor.instance.refresh();
      await tester.pump();
      expect(find.text(messages.noInternetConnection), findsOneWidget);
      provider.offline = false;
      connected = true;
      await NetworkStatusMonitor.instance.refresh();
      await tester.pump();
      gate.complete();
      await waitForWidgetCondition(
        tester,
        () =>
            find.byType(FlutterMap).evaluate().isNotEmpty &&
            find.text(messages.connectionProblem).evaluate().isEmpty &&
            find
                .byWidgetPredicate(
                  (widget) => widget is RawImage && widget.image != null,
                )
                .evaluate()
                .isNotEmpty,
        debug: () =>
            'evictions=$evictionsBeforeReconnect/${provider.evictions}, '
            'map=${find.byType(FlutterMap).evaluate().length}, '
            'notice=${find.text(messages.connectionProblem).evaluate().length}, '
            'status=${NetworkStatusMonitor.instance.status}',
      );
      expect(provider.evictions, evictionsBeforeReconnect);
      expect(tester.takeException(), isNull);
    } finally {
      if (!gate.isCompleted) gate.complete();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      messenger.setMockMethodCallHandler(connectivity, null);
      messenger.setMockMethodCallHandler(events, null);
    }
  });
}

class _MapLayout {
  const _MapLayout(
      this.name, this.size, this.textScale, this.mapVisibleDuringFailure);

  final String name;
  final Size size;
  final double textScale;
  final bool mapVisibleDuringFailure;
}

void _expectAttributionFullyVisible(WidgetTester tester, Finder credits) {
  final creditRect = tester.getRect(credits);
  final mapRect = tester.getRect(find.byType(FlutterMap));
  expect(creditRect.left, greaterThanOrEqualTo(mapRect.left));
  expect(creditRect.top, greaterThanOrEqualTo(mapRect.top));
  expect(creditRect.right, lessThanOrEqualTo(mapRect.right));
  expect(creditRect.bottom, lessThanOrEqualTo(mapRect.bottom));
}

class _ControlledTileProvider extends TileProvider {
  bool offline = true;
  Future<void>? evictionGate;
  int requests = 0;
  int evictions = 0;
  int disposeCount = 0;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    requests++;
    if (offline) {
      return _OfflineImageProvider(evictionGate, () => evictions++);
    }
    return MemoryImage(testPng);
  }

  @override
  void dispose() {
    disposeCount++;
    super.dispose();
  }
}

class _OfflineImageProvider extends ImageProvider<_OfflineImageProvider> {
  _OfflineImageProvider(this.evictionGate, this.onEvict);

  final Future<void>? evictionGate;
  final VoidCallback onEvict;

  @override
  Future<_OfflineImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
          _OfflineImageProvider key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(
        Future<ImageInfo>.error(const SocketException('network unavailable')),
      );

  @override
  Future<bool> evict({
    ImageCache? cache,
    ImageConfiguration configuration = ImageConfiguration.empty,
  }) async {
    onEvict();
    if (evictionGate != null) await evictionGate;
    return super.evict(cache: cache, configuration: configuration);
  }
}

class _ControlledNetworkTileProvider extends NetworkTileProvider {
  _ControlledNetworkTileProvider(this.namespace, http.BaseClient client)
      : super(httpClient: client);

  final String namespace;

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) =>
      'https://tiles.example.test/$namespace/${coordinates.z}/${coordinates.x}/${coordinates.y}.png';
}

class _ControlledHttpClient extends http.BaseClient {
  bool offline = true;
  int requests = 0;
  int closeCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests++;
    if (offline) {
      throw http.ClientException('Connection closed', request.url);
    }
    return http.StreamedResponse(
      Stream.value(testPng),
      200,
      contentLength: testPng.length,
      request: request,
    );
  }

  @override
  void close() {
    closeCount++;
    super.close();
  }
}
