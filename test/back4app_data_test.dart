import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/database_config/back4app_config.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_service.dart';
import 'package:vodic_kroz_valjevo/helper/images_loader_helper.dart';

import 'support/tour_fixtures.dart';

void main() {
  late TourFixtureData fixtures;

  setUpAll(() {
    fixtures = makeTourFixtures();
  });

  test('maps all categories and localized fields', () {
    for (final collection in TourCollection.values) {
      final records = fixtures[collection]!;
      expect(records.length, fixtureCounts[collection]);
      for (final record in records) {
        final objectId = 'object${record['id']}';
        final remote = {...record, 'objectId': objectId};
        for (final locale in TourDataMapper.supportedLocales) {
          final data = TourDataMapper.forLocale(collection, remote, locale);
          expect(data['id'], objectId);
          if (collection == TourCollection.aboutCity) {
            expect(data['title'], record['legend_title_$locale']);
            expect(data['description'], record['legend_description_$locale']);
            expect(data['history'], record['history_$locale']);
          } else {
            expect(data['title'], record['title_$locale']);
            expect(data['latitude'], isA<double>());
            expect(data['longitude'], isA<double>());
            if (collection == TourCollection.sights ||
                collection == TourCollection.sports ||
                collection == TourCollection.parks) {
              expect(data['description'], record['description_$locale']);
            }
            if (collection == TourCollection.hotels) {
              expect(data['noStars'], isA<int>());
            }
          }
        }
      }
    }
  });

  test('lists and retrieves localized data using the Parse class and object ID',
      () async {
    final source = _FakeTourDataSource(fixtures);
    final service = TourDataService(source);

    for (final collection in TourCollection.values) {
      final name = TourDataMapper.className(collection);
      final list = await service.list(collection, 'sr_Cyrl');
      expect(source.lastClass, name);
      expect(list.length, fixtures[collection]!.length);
      expect(list.first['id'], 'object1');

      final detail = await service.get(collection, 'object1', 'de');
      expect(source.lastClass, name);
      expect(source.lastObjectId, isNull);
      final titleKey = collection == TourCollection.aboutCity
          ? 'legend_title_de'
          : 'title_de';
      expect(detail['title'], fixtures[collection]!.first[titleKey]);
    }
    final coldSource = _FakeTourDataSource(fixtures);
    await TourDataService(coldSource)
        .get(TourCollection.sights, 'object1', 'en');
    expect(coldSource.lastObjectId, 'object1');
  });

  test('rejects missing translations, invalid coordinates and star counts', () {
    final sight = {
      ...fixtures[TourCollection.sights]!.first,
      'objectId': 'one'
    };
    sight.remove('description_de');
    expect(
      () => TourDataMapper.forLocale(TourCollection.sights, sight, 'de'),
      throwsFormatException,
    );

    final hotel = {
      ...fixtures[TourCollection.hotels]!.first,
      'objectId': 'one'
    };
    hotel['latitude'] = 999;
    expect(
      () => TourDataMapper.forLocale(TourCollection.hotels, hotel, 'en'),
      throwsFormatException,
    );
    hotel['latitude'] = 44;
    hotel['noStars'] = 'three';
    expect(
      () => TourDataMapper.forLocale(TourCollection.hotels, hotel, 'en'),
      throwsFormatException,
    );
    expect(
      () => TourDataMapper.forLocale(TourCollection.hotels, hotel, 'fr'),
      throwsArgumentError,
    );
  });

  test('validates required Back4App settings and HTTPS', () {
    final valid = {
      'KEY_APPLICATION_ID': 'app',
      'KEY_CLIENT_KEY': 'client',
      'KEY_PARSE_SERVER_URL': 'https://example.test/parse',
    };
    expect(
      Back4AppConfig.fromEnvironment(valid).serverUrl.path,
      '/parse',
    );
    expect(
      () => Back4AppConfig.fromEnvironment({...valid, 'KEY_CLIENT_KEY': ''}),
      throwsStateError,
    );
    expect(
      () => Back4AppConfig.fromEnvironment({
        ...valid,
        'KEY_PARSE_SERVER_URL': 'http://example.test/parse',
      }),
      throwsStateError,
    );
    expect(
      () => Back4AppConfig.fromEnvironment({
        ...valid,
        'KEY_PARSE_SERVER_URL': 'https://example.test/parse?key=secret',
      }),
      throwsStateError,
    );
    expect(
      Back4AppConfig.fromEnvironment({
        ...valid,
        'KEY_PARSE_SERVER_URL': 'http://127.0.0.1:1234/parse',
      }).serverUrl.scheme,
      'http',
    );
    expect(
      () => Back4AppConfig.fromEnvironment(
          {...valid, 'SERVER_ONLY_SECRET': 'private'}),
      throwsFormatException,
    );
  });

  test('declares the public .env asset but not administrative configuration',
      () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    expect(RegExp(r'^\s*-\s+\.env\s*$', multiLine: true).hasMatch(pubspec),
        isTrue);
    expect(
        RegExp(r'^\s*-\s+\.env\.admin\s*$', multiLine: true).hasMatch(pubspec),
        isFalse);
    expect(
        RegExp(r'^\s*-\s+\.env\.public\.json\s*$', multiLine: true)
            .hasMatch(pubspec),
        isFalse);
  });

  test('loads bundled paths and online image URLs with the right provider', () {
    expect(tourImageProvider('images/example.jpg'), isA<AssetImage>());
    expect(tourImageProvider('https://example.test/photo.jpg'),
        isA<NetworkImage>());
    final thumbnail =
        tourImageProvider('https://example.test/photo.jpg', cacheWidth: 400);
    expect(thumbnail, isA<ResizeImage>());
    expect((thumbnail as ResizeImage).width, 400);
    expect(thumbnail.imageProvider, isA<NetworkImage>());
    expect(() => tourImageProvider('images/example.jpg', cacheWidth: 0),
        throwsArgumentError);
  });
}

class _FakeTourDataSource implements TourDataSource {
  _FakeTourDataSource(this.fixtures);

  final TourFixtureData fixtures;
  String? lastClass;
  String? lastObjectId;

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String className) async {
    lastClass = className;
    final collection = TourCollection.values
        .firstWhere((value) => TourDataMapper.className(value) == className);
    return fixtures[collection]!
        .map((row) => {...row, 'objectId': 'object${row['id']}'})
        .toList();
  }

  @override
  Future<Map<String, dynamic>> fetchById(
      String className, String objectId) async {
    lastObjectId = objectId;
    final records = await fetchAll(className);
    return records.singleWhere((record) => record['objectId'] == objectId);
  }
}
