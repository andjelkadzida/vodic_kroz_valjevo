import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_service.dart';
import 'package:vodic_kroz_valjevo/l10n/app_localizations.dart';
import 'package:vodic_kroz_valjevo/pages/about_city.dart';
import 'package:vodic_kroz_valjevo/pages/hotels/hotel_details.dart';
import 'package:vodic_kroz_valjevo/pages/parks/park_details.dart';
import 'package:vodic_kroz_valjevo/pages/restaurants/restaurant_details.dart';
import 'package:vodic_kroz_valjevo/pages/sights/sight_details_page.dart';
import 'package:vodic_kroz_valjevo/pages/sights/sights.dart';
import 'package:vodic_kroz_valjevo/pages/sport_and_recreation.dart';
import 'package:vodic_kroz_valjevo/pages/sports/sport_details.dart';

import 'support/fake_parse_client.dart';
import 'support/tour_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TourFixtureData fixtures;
  late FakeParseClient client;

  setUpAll(() async {
    fixtures = makeTourFixtures();
    client = FakeParseClient(fixtures);
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
    for (final collection in TourCollection.values) {
      TourDataService.instance.refresh(collection);
    }
    client.requests.clear();
    client.forbiddenClass = null;
    client.emptyClasses.clear();
  });

  test('queries every page in a stable order and fetches details by objectId',
      () async {
    final service =
        TourDataService(ParseTourDataSource(client: client, pageSize: 5));
    final sights = await service.list(TourCollection.sights, 'en');
    expect(sights.length, 12);
    expect(sights.first['title'],
        fixtures[TourCollection.sights]!.first['title_en']);
    expect(
      client.requests.map((uri) => uri.queryParameters['skip']).toList(),
      ['0', '5', '10'],
    );
    for (final request in client.requests) {
      expect(request.path, '/parse/classes/Sights');
      expect(request.queryParameters['limit'], '5');
      expect(request.queryParameters['order'], 'createdAt,objectId');
    }

    final requestsBeforeDetail = client.requests.length;
    final detail = await service.get(TourCollection.sights, 'Sights1', 'de');
    expect(detail['id'], 'Sights1');
    expect(detail['title'], fixtures[TourCollection.sights]!.first['title_de']);
    expect(client.requests.length, requestsBeforeDetail);
    await TourDataService(ParseTourDataSource(client: client))
        .get(TourCollection.sights, 'Sights1', 'de');
    expect(client.requests.last.path, '/parse/classes/Sights/Sights1');
  });

  test('uses the correct remote class for all collections and languages',
      () async {
    final service = TourDataService(ParseTourDataSource(client: client));
    for (final collection in TourCollection.values) {
      final name = TourDataMapper.className(collection);
      for (final locale in TourDataMapper.supportedLocales) {
        final records = await service.list(collection, locale);
        expect(records.length, fixtures[collection]!.length);
        final titleKey = collection == TourCollection.aboutCity
            ? 'legend_title_$locale'
            : 'title_$locale';
        expect(records.first['title'], fixtures[collection]!.first[titleKey]);
        expect(client.requests.last.path, '/parse/classes/$name');
      }
    }
  });

  test('distinguishes empty classes from denied or missing records', () async {
    final source = ParseTourDataSource(client: client);
    client.emptyClasses.add('Hotels');
    expect(await source.fetchAll('Hotels'), isEmpty);

    client.forbiddenClass = 'Restaurants';
    await expectLater(
      source.fetchAll('Restaurants'),
      throwsA(isA<Back4AppDataException>().having((e) => e.code, 'code', 119)),
    );
    await expectLater(
      source.fetchById('Sights', 'missing'),
      throwsA(isA<Back4AppDataException>().having((e) => e.code, 'code', 101)),
    );
  });

  testWidgets('a localized sight opens its Back4App detail record',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Sights(),
      ),
    );
    await tester.pumpAndSettle();

    final title = fixtures[TourCollection.sights]!.first['title_de'] as String;
    expect(find.text(title), findsOneWidget);
    await tester.tap(find.text(title));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.byType(SightDetailsPage), findsOneWidget);
    expect(client.requests.last.path, '/parse/classes/Sights');
    expect(find.text(fixtures[TourCollection.sights]!.first['description_de']),
        findsOneWidget);
  });

  testWidgets('refresh reloads updated Back4App data', (tester) async {
    final first = client.records['Sights']!.first;
    final original = first['title_en'];
    addTearDown(() => first['title_en'] = original);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Sights(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(client.requests.length, 1);
    first['title_en'] = 'Freshly updated';
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(client.requests.length, 2);
    expect(find.text('Freshly updated'), findsOneWidget);
  });

  for (final collection in [
    TourCollection.parks,
    TourCollection.sports,
    TourCollection.hotels,
    TourCollection.restaurants,
  ]) {
    testWidgets(
        'reads ${TourDataMapper.className(collection)} details in Cyrillic',
        (tester) async {
      final name = TourDataMapper.className(collection);
      final objectId = '${name}1';
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale.fromSubtags(
            languageCode: 'sr',
            scriptCode: 'Cyrl',
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _detailsPage(collection, objectId),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(client.requests.last.path, '/parse/classes/$name/$objectId');
      expect(find.text(fixtures[collection]!.first['title_sr_Cyrl']),
          findsWidgets);
      if (collection == TourCollection.parks ||
          collection == TourCollection.sports) {
        expect(find.text(fixtures[collection]!.first['description_sr_Cyrl']),
            findsOneWidget);
      }
    });
  }

  testWidgets('reads localized city history and legends', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 2000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AboutCity(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(client.requests.last.path, '/parse/classes/AboutCity');
    final context = tester.element(find.byType(AboutCity));
    final localizations = AppLocalizations.of(context)!;
    final historyHeader = find.text(localizations.historyOfTheCity);
    await tester.ensureVisible(historyHeader);
    await tester.tap(historyHeader);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(
        find.text(fixtures[TourCollection.aboutCity]!.first['history_sr_Latn']),
        findsOneWidget);

    final legendHeader = find.text(localizations.legendOfTheCity);
    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(legendHeader, 300, scrollable: scrollable);
    await tester.tap(legendHeader);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(
        find.text(
            fixtures[TourCollection.aboutCity]!.first['legend_title_sr_Latn']),
        findsOneWidget);
  });

  testWidgets('loads both recreation collections into their sliders',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SportsAndRecreation(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(client.requests.map((uri) => uri.path),
        containsAll(['/parse/classes/Parks', '/parse/classes/Sports']));
    expect(find.text(fixtures[TourCollection.parks]!.first['title_en']),
        findsOneWidget);
    expect(find.text(fixtures[TourCollection.sports]!.first['title_en']),
        findsOneWidget);
  });
}

Widget _detailsPage(TourCollection collection, String objectId) {
  switch (collection) {
    case TourCollection.parks:
      return ParkDetailsPage(parkId: objectId);
    case TourCollection.sports:
      return SportDetailsPage(sportId: objectId);
    case TourCollection.hotels:
      return HotelDetailsPage(hotelId: objectId);
    case TourCollection.restaurants:
      return RestaurantDetailsPage(restaurantId: objectId);
    case TourCollection.sights:
    case TourCollection.aboutCity:
      throw ArgumentError.value(collection, 'collection');
  }
}
