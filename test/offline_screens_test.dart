import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/database_config/tour_data_service.dart';
import '../lib/helper/internet_connectivity.dart';
import '../lib/l10n/app_localizations.dart';
import '../lib/maps_navigation/map_builder.dart';
import '../lib/pages/about_city.dart';
import '../lib/pages/hotels/hotel_details.dart';
import '../lib/pages/hotels/hotels.dart';
import '../lib/pages/parks/park_details.dart';
import '../lib/pages/restaurants/restaurant_details.dart';
import '../lib/pages/restaurants/restaurants.dart';
import '../lib/pages/sights/sight_details_page.dart';
import '../lib/pages/sights/sights.dart';
import '../lib/pages/sport_and_recreation.dart';
import '../lib/pages/sports/sport_details.dart';

import 'support/fake_parse_client.dart';
import 'support/tour_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const events = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
  late _OfflineParseClient client;
  var connected = false;

  setUpAll(() async {
    client = _OfflineParseClient(makeTourFixtures());
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
    connected = false;
    client.offline = true;
    client.requests.clear();
    SharedPreferences.setMockInitialValues({});
    for (final collection in TourCollection.values) {
      TourDataService.instance.refresh(collection);
    }
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        connectivity, (_) async => [connected ? 'wifi' : 'none']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, null);
    messenger.setMockMethodCallHandler(events, null);
  });

  final screens = <_Screen>[
    _Screen('sights', () => Sights()),
    _Screen('recreation', () => const SportsAndRecreation()),
    _Screen('city facts', () => const AboutCity()),
    _Screen('hotels', () => const Hotels()),
    _Screen('restaurants', () => const Restaurants()),
    _Screen('sight details', () => const SightDetailsPage(sightId: 'Sights1')),
    _Screen('park details', () => const ParkDetailsPage(parkId: 'Parks1')),
    _Screen('sport details', () => const SportDetailsPage(sportId: 'Sports1')),
    _Screen('hotel details', () => const HotelDetailsPage(hotelId: 'Hotels1')),
    _Screen(
      'restaurant details',
      () => const RestaurantDetailsPage(restaurantId: 'Restaurants1'),
    ),
  ];

  for (final screen in screens) {
    testWidgets('${screen.name} shows an offline message and settings',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_app(screen.build(), const Locale('de')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        final context = tester.element(find.byType(Scaffold).first);
        final messages = AppLocalizations.of(context)!;
        expect(find.text(messages.noInternetConnection), findsWidgets);
        expect(find.text(messages.openSettings), findsWidgets);
        expect(find.text(messages.errorLoadingData), findsNothing);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        semantics.dispose();
      }
    });
  }

  final layouts = <_OfflineLayout>[
    _OfflineLayout('sights large portrait', () => Sights(),
        const Size(320, 480), const Locale('de'), 3),
    _OfflineLayout(
        'recreation large portrait',
        () => const SportsAndRecreation(),
        const Size(320, 480),
        const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'),
        3),
    _OfflineLayout('city landscape', () => const AboutCity(),
        const Size(640, 360), const Locale('en'), 2),
    _OfflineLayout(
        'hotel tablet',
        () => const HotelDetailsPage(hotelId: 'Hotels1'),
        const Size(800, 1280),
        const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
        2),
  ];

  for (final layout in layouts) {
    testWidgets('offline guidance remains accessible on ${layout.name}',
        (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = layout.size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      try {
        await tester.pumpWidget(
            _app(layout.build(), layout.locale, textScale: layout.textScale));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        final context = tester.element(find.byType(Scaffold).first);
        final messages = AppLocalizations.of(context)!;
        final settings = find.text(messages.openSettings).first;
        expect(find.text(messages.noInternetConnection), findsWidgets);
        await Scrollable.ensureVisible(tester.element(settings),
            alignment: 0.5);
        await tester.pump();
        expect(settings.hitTestable(), findsOneWidget);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        semantics.dispose();
      }
    });
  }

  testWidgets('a failed guide request reloads after connectivity returns',
      (tester) async {
    try {
      await tester.pumpWidget(_app(Sights(), const Locale('en')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final context = tester.element(find.byType(Sights));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noInternetConnection), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      client.offline = false;
      connected = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(
        find.text(client.records['Sights']!.first['title_en']),
        findsOneWidget,
      );
      expect(find.text(messages.noInternetConnection), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('cached city data stays visible after the connection is lost',
      (tester) async {
    client.offline = false;
    connected = true;
    try {
      await tester.pumpWidget(_app(const AboutCity(), const Locale('en')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final context = tester.element(find.byType(AboutCity));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.surface), findsOneWidget);
      final requests = client.requests.length;

      client.offline = true;
      connected = false;
      await NetworkStatusMonitor.instance.refresh();
      await tester.pump();
      expect(find.text(messages.surface), findsOneWidget);
      expect(find.text(messages.noInternetConnection), findsNothing);
      expect(client.requests, hasLength(requests));
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('the map opens after connectivity returns', (tester) async {
    try {
      await tester.pumpWidget(_app(
          MapPage(tileProvider: _AssetTileProvider()), const Locale('en')));
      await tester.pump();
      await tester.pump();
      final context = tester.element(find.byType(MapPage));
      final messages = AppLocalizations.of(context)!;
      expect(find.text(messages.noInternetConnection), findsOneWidget);
      expect(find.text(messages.openSettings), findsOneWidget);

      connected = true;
      await NetworkStatusMonitor.instance.refresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text(messages.noInternetConnection), findsNothing);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('reconnecting the map keeps its supplied tile provider usable',
      (tester) async {
    final provider = _AssetTileProvider();
    connected = true;
    try {
      await tester.pumpWidget(
          _app(MapPage(tileProvider: provider), const Locale('en')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(FlutterMap), findsOneWidget);
      final context = tester.element(find.byType(MapPage));
      final messages = AppLocalizations.of(context)!;
      final controller =
          tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
      final initialZoom = controller.camera.zoom;
      await tester.tap(find.byTooltip(messages.zoomIn));
      await tester.pump();
      expect(controller.camera.zoom, greaterThan(initialZoom));
      final cameraBeforeDisconnect = controller.camera;

      connected = false;
      await NetworkStatusMonitor.instance.refresh();
      await tester.pump();
      expect(find.byType(FlutterMap), findsNothing);
      expect(provider.disposeCount, 0);

      connected = true;
      await NetworkStatusMonitor.instance.refresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(provider.disposeCount, 0);
      final camera = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!
          .camera;
      expect(camera.zoom, cameraBeforeDisconnect.zoom);
      expect(camera.center, cameraBeforeDisconnect.center);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
    expect(provider.disposeCount, 1);
  });

  testWidgets('custom tile cancellation support remains available',
      (tester) async {
    final provider = _CancelableTileProvider();
    connected = true;
    try {
      await tester.pumpWidget(
          _app(MapPage(tileProvider: provider), const Locale('en')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(provider.requests, greaterThan(0));
      expect(provider.disposeCount, 0);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
    expect(provider.cancellations, provider.requests);
    expect(provider.disposeCount, 1);
  });
}

Widget _app(Widget home, Locale locale, {double textScale = 1}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: home,
    );

class _Screen {
  const _Screen(this.name, this.build);

  final String name;
  final Widget Function() build;
}

class _OfflineLayout {
  const _OfflineLayout(
      this.name, this.build, this.size, this.locale, this.textScale);

  final String name;
  final Widget Function() build;
  final Size size;
  final Locale locale;
  final double textScale;
}

class _OfflineParseClient extends FakeParseClient {
  _OfflineParseClient(TourFixtureData fixtures) : super(fixtures);

  bool offline = true;

  @override
  Future<ParseNetworkResponse> get(
    String path, {
    ParseNetworkOptions? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (offline) {
      return ParseNetworkResponse(
        statusCode: ParseError.otherCause,
        data: jsonEncode({
          'code': ParseError.otherCause,
          'error': 'Network request failed',
        }),
      );
    }
    return super.get(
      path,
      options: options,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

class _AssetTileProvider extends TileProvider {
  int disposeCount = 0;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      const AssetImage('images/appLogo.png');

  @override
  void dispose() {
    disposeCount++;
    super.dispose();
  }
}

class _CancelableTileProvider extends TileProvider {
  int requests = 0;
  int cancellations = 0;
  int disposeCount = 0;

  @override
  bool get supportsCancelLoading => true;

  @override
  ImageProvider getImageWithCancelLoadingSupport(
    TileCoordinates coordinates,
    TileLayer options,
    Future<void> cancelLoading,
  ) {
    requests++;
    cancelLoading.then((_) => cancellations++);
    return const AssetImage('images/appLogo.png');
  }

  @override
  void dispose() {
    disposeCount++;
    super.dispose();
  }
}
