import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_service.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/maps_navigation/map_builder.dart';
import 'package:vodic_kroz_valjevo/pages/about_city.dart';
import 'package:vodic_kroz_valjevo/pages/bug_report.dart';
import 'package:vodic_kroz_valjevo/pages/home_page.dart';
import 'package:vodic_kroz_valjevo/pages/hotels/hotel_details.dart';
import 'package:vodic_kroz_valjevo/pages/hotels/hotels.dart';
import 'package:vodic_kroz_valjevo/pages/hotels_and_restaurants.dart';
import 'package:vodic_kroz_valjevo/pages/menu/menu_page.dart';
import 'package:vodic_kroz_valjevo/pages/parks/park_details.dart';
import 'package:vodic_kroz_valjevo/pages/restaurants/restaurant_details.dart';
import 'package:vodic_kroz_valjevo/pages/restaurants/restaurants.dart';
import 'package:vodic_kroz_valjevo/pages/sights/sight_details_page.dart';
import 'package:vodic_kroz_valjevo/pages/sights/sights.dart';
import 'package:vodic_kroz_valjevo/pages/sport_and_recreation.dart';
import 'package:vodic_kroz_valjevo/pages/sports/sport_details.dart';

import 'support/fake_parse_client.dart';
import 'support/tour_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeParseClient client;
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const events = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
  const tts = MethodChannel('flutter_tts');

  setUpAll(() async {
    client = FakeParseClient(makeTourFixtures());
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
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, (_) async => ['none']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
    messenger.setMockMethodCallHandler(tts, (_) async => 1);
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(connectivity, null);
    messenger.setMockMethodCallHandler(events, null);
    messenger.setMockMethodCallHandler(tts, null);
  });

  final screens = <_Screen>[
    _Screen('home', () => const HomePage()),
    _Screen('menu', () => const MenuPage()),
    _Screen('sights', () => Sights()),
    _Screen('recreation', () => const SportsAndRecreation()),
    _Screen('about city', () => const AboutCity()),
    _Screen('hotel and restaurant menu', () => const HotelsAndRestaurants()),
    _Screen('hotels', () => const Hotels()),
    _Screen('restaurants', () => const Restaurants()),
    _Screen('map', () => const MapPage()),
    _Screen('sight details', () => const SightDetailsPage(sightId: 'Sights1')),
    _Screen('park details', () => const ParkDetailsPage(parkId: 'Parks1')),
    _Screen('sport details', () => const SportDetailsPage(sportId: 'Sports1')),
    _Screen('hotel details', () => const HotelDetailsPage(hotelId: 'Hotels1')),
    _Screen('restaurant details',
        () => const RestaurantDetailsPage(restaurantId: 'Restaurants1')),
    _Screen('bug report', () => const BugReportPage()),
  ];

  for (final screen in screens) {
    testWidgets('${screen.name} exposes labeled, usable controls',
        (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      try {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.5),
                disableAnimations: true,
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
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        semantics.dispose();
      }
    });
  }
}

class _Screen {
  const _Screen(this.name, this.build);

  final String name;
  final Widget Function() build;
}
