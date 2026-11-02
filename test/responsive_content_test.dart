import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/database_config/tour_data_service.dart';
import '../lib/l10n/app_localizations.dart';
import '../lib/maps_navigation/map_builder.dart';
import '../lib/pages/about_city.dart';
import '../lib/pages/bug_report.dart';
import '../lib/pages/home_page.dart';
import '../lib/pages/hotels/hotel_details.dart';
import '../lib/pages/hotels/hotels.dart';
import '../lib/pages/hotels_and_restaurants.dart';
import '../lib/pages/menu/menu_page.dart';
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
  late FakeParseClient client;
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const connectivityEvents =
      MethodChannel('dev.fluttercommunity.plus/connectivity_status');
  const tts = MethodChannel('flutter_tts');

  setUpAll(() async {
    client = FakeParseClient(makeTourFixtures());
    for (final locale in TourDataMapper.supportedLocales) {
      final language = locale == 'sr_Cyrl' ? 'Ћирилица' : 'Translated';
      client.records['Sights']!.first['title_$locale'] =
          '$language historical landmark with a deliberately long descriptive name';
      client.records['Sports']!.first['title_$locale'] =
          '$language sport and recreation field';
      client.records['Parks']!.first['title_$locale'] =
          '$language park and nature reserve';
      client.records['AboutCity']!.first['legend_title_$locale'] =
          '$language local legend with a deliberately long descriptive title';
    }
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
    for (final collection in TourCollection.values) {
      TourDataService.instance.refresh(collection);
    }
    client.requests.clear();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, (_) async => ['none']);
    messenger.setMockMethodCallHandler(connectivityEvents, (_) async => null);
    messenger.setMockMethodCallHandler(tts, (_) async => 1);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, null);
    messenger.setMockMethodCallHandler(connectivityEvents, null);
    messenger.setMockMethodCallHandler(tts, null);
  });

  final screens = <_Screen>[
    _Screen('home', () => const HomePage()),
    _Screen('menu', () => const MenuPage()),
    _Screen('sights', () => Sights(), loadsData: true),
    _Screen('recreation', () => const SportsAndRecreation(), loadsData: true),
    _Screen('about city', () => const AboutCity(), loadsData: true),
    _Screen('hotel and restaurant menu', () => const HotelsAndRestaurants()),
    _Screen('hotels map', () => const Hotels(), loadsData: true),
    _Screen('restaurants map', () => const Restaurants(), loadsData: true),
    _Screen('map', () => const MapPage()),
    _Screen('sight details', () => const SightDetailsPage(sightId: 'Sights1'),
        loadsData: true),
    _Screen('park details', () => const ParkDetailsPage(parkId: 'Parks1'),
        loadsData: true),
    _Screen('sport details', () => const SportDetailsPage(sportId: 'Sports1'),
        loadsData: true),
    _Screen('hotel details', () => const HotelDetailsPage(hotelId: 'Hotels1'),
        loadsData: true),
    _Screen(
      'restaurant details',
      () => const RestaurantDetailsPage(restaurantId: 'Restaurants1'),
      loadsData: true,
    ),
    _Screen('bug report', () => const BugReportPage()),
  ];
  const scenarios = <_Scenario>[
    _Scenario('small portrait', Size(320, 480), Locale('de'), 2),
    _Scenario('small landscape', Size(640, 360),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'), 2),
    _Scenario('phone', Size(390, 844), Locale('en'), 1),
    _Scenario('tablet portrait', Size(800, 1280),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'), 2),
    _Scenario('tablet landscape', Size(1280, 800), Locale('de'), 2),
    _Scenario('landscape cutout', Size(800, 360), Locale('en'), 2,
        horizontalInset: 28),
    _Scenario('extra large text', Size(320, 480), Locale('de'), 3),
    _Scenario('English large portrait', Size(320, 480), Locale('en'), 3),
    _Scenario('Latin large portrait', Size(320, 480),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'), 3),
    _Scenario('Cyrillic large portrait', Size(320, 480),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl'), 3),
    _Scenario('German landscape', Size(640, 360), Locale('de'), 2),
    _Scenario('English landscape', Size(640, 360), Locale('en'), 2),
    _Scenario('Latin landscape', Size(640, 360),
        Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'), 2),
  ];

  for (final screen in screens) {
    for (final scenario in scenarios) {
      testWidgets('${screen.name} fits ${scenario.name}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = scenario.size;
        if (scenario.horizontalInset > 0) {
          tester.view.padding = FakeViewPadding(
            left: scenario.horizontalInset,
            right: scenario.horizontalInset,
          );
          addTearDown(tester.view.resetPadding);
        }
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        try {
          await tester.pumpWidget(
            MaterialApp(
              locale: scenario.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scenario.textScale),
                ),
                child: child!,
              ),
              home: screen.build(),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump();
          expect(tester.takeException(), isNull);
          if (screen.loadsData) expect(client.requests, isNotEmpty);
          _expectTextFits(tester);
          final verticalScrollables = find.byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                (widget.axisDirection == AxisDirection.down ||
                    widget.axisDirection == AxisDirection.up),
          );
          final bodyScrollables =
              verticalScrollables.evaluate().where((element) {
            var inAppBar = false;
            element.visitAncestorElements((ancestor) {
              if (ancestor.widget is AppBar) {
                inAppBar = true;
                return false;
              }
              return true;
            });
            return !inAppBar;
          }).toList();
          if (bodyScrollables.isNotEmpty) {
            final bodyScrollable = find.byWidget(bodyScrollables.first.widget);
            expect(tester.getSize(bodyScrollable).height, greaterThan(0));
            await tester.drag(
              bodyScrollable,
              Offset(0, -scenario.size.height * 2),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            expect(tester.takeException(), isNull);
            _expectTextFits(tester);
          }
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        }
      });
    }
  }

  for (final scenario in scenarios.take(3)) {
    testWidgets('city details remain readable on ${scenario.name}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = scenario.size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          locale: scenario.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scenario.textScale),
            ),
            child: child!,
          ),
          home: const AboutCity(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      final context = tester.element(find.byType(AboutCity));
      final messages = AppLocalizations.of(context)!;
      final scrollable = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      final historyHeader = find.text(messages.historyOfTheCity);
      await tester.scrollUntilVisible(historyHeader, 250,
          scrollable: scrollable);
      await tester.pump();
      expect(historyHeader.hitTestable(), findsOneWidget);
      await tester.tap(historyHeader);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      _expectTextFits(tester);

      final legendHeader = find.text(messages.legendOfTheCity);
      await tester.scrollUntilVisible(legendHeader, 250,
          scrollable: scrollable);
      await tester.pump();
      expect(legendHeader.hitTestable(), findsOneWidget);
      await tester.tap(legendHeader);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final longTitle = client.records['AboutCity']!
          .first['legend_title_${messages.localeName}'] as String;
      final legend = find.text(longTitle);
      await tester.scrollUntilVisible(legend, 250, scrollable: scrollable);
      await tester.pump();
      expect(legend, findsOneWidget);
      expect(
          legend.hitTestable(at: const Alignment(-0.9, -0.9)), findsOneWidget);
      _expectTextFits(tester);
      await tester.tapAt(tester.getTopLeft(legend) + const Offset(8, 8));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      _expectTextFits(tester);
    });
  }

  testWidgets('online map attribution remains visible at large text sizes',
      (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 480);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivity, (_) async => ['wifi']);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(3)),
          child: child!,
        ),
        home: MapPage(tileProvider: _AssetTileProvider()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final credit = find.text('© OpenStreetMap');
    expect(credit, findsOneWidget);
    expect(credit.hitTestable(), findsOneWidget);
    _expectTextFits(tester);
    final context = tester.element(find.byType(MapPage));
    final messages = AppLocalizations.of(context)!;
    final controller =
        tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
    final originalZoom = controller.camera.zoom;
    final originalCenter = controller.camera.center;
    final zoomButton = find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == messages.zoomIn,
    );
    final zoomIcon =
        find.descendant(of: zoomButton, matching: find.byIcon(Icons.zoom_in));
    Focus.of(tester.element(zoomIcon)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(controller.camera.zoom, greaterThan(originalZoom));
    await tester.tap(find.byTooltip(messages.moveMapUp));
    await tester.pump();
    expect(controller.camera.center, isNot(originalCenter));
    await tester.tap(find.byTooltip(messages.resetMap));
    await tester.pump();
    expect(controller.camera.zoom, originalZoom);
    expect(controller.camera.center, originalCenter);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });
}

class _AssetTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      const AssetImage('images/appLogo.png');
}

void _expectTextFits(WidgetTester tester) {
  for (final element in find.byType(RichText).evaluate()) {
    var hiddenNavigationLabel = false;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is BottomNavigationBar) {
        hiddenNavigationLabel = true;
        return false;
      }
      return true;
    });
    if (hiddenNavigationLabel) continue;
    final richText = element.widget as RichText;
    final span = richText.text;
    var hasWidgetSpan = false;
    span.visitChildren((child) {
      if (child is WidgetSpan) hasWidgetSpan = true;
      return !hasWidgetSpan;
    });
    if (hasWidgetSpan) continue;
    final render = element.renderObject;
    if (render is! RenderBox || !render.hasSize || render.size.width <= 0) {
      continue;
    }
    final painter = TextPainter(
      text: span,
      textDirection: richText.textDirection ?? TextDirection.ltr,
      textAlign: richText.textAlign,
      textScaler: richText.textScaler,
      locale: richText.locale,
      strutStyle: richText.strutStyle,
      textWidthBasis: richText.textWidthBasis,
      textHeightBehavior: richText.textHeightBehavior,
    )..layout(maxWidth: render.size.width);
    expect(
      painter.height,
      lessThanOrEqualTo(render.size.height + 0.1),
      reason: 'Text must not be clipped: ${span.toPlainText()}',
    );
    painter.dispose();
  }
}

class _Screen {
  const _Screen(this.name, this.build, {this.loadsData = false});

  final String name;
  final Widget Function() build;
  final bool loadsData;
}

class _Scenario {
  const _Scenario(this.name, this.size, this.locale, this.textScale,
      {this.horizontalInset = 0});

  final String name;
  final Size size;
  final Locale locale;
  final double textScale;
  final double horizontalInset;
}
