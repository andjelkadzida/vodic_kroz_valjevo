import 'dart:async';
import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_service.dart';

import 'support/tour_fixtures.dart';

void main() {
  late _CountingSource source;
  late DateTime now;
  late TourDataService service;

  setUp(() {
    source = _CountingSource();
    now = DateTime.utc(2026, 1, 1);
    service = TourDataService(source, clock: () => now, maxCachedDetails: 2);
  });

  test('shares one collection request across languages and detail navigation',
      () async {
    final english = await service.list(TourCollection.sights, 'en');
    final german = await service.list(TourCollection.sights, 'de');
    final detail =
        await service.get(TourCollection.sights, 'Sights1', 'sr_Cyrl');
    expect(source.listCalls['Sights'], 1);
    expect(source.detailCalls, 0);
    expect(english.first['title'], source.rows['Sights']!.first['title_en']);
    expect(german.first['title'], source.rows['Sights']!.first['title_de']);
    expect(detail['title'], source.rows['Sights']!.first['title_sr_Cyrl']);
  });

  test('uses unexpired memory offline and expires exactly after five minutes',
      () async {
    await service.list(TourCollection.sights, 'en');
    source.offline = true;
    now = now.add(const Duration(minutes: 4, seconds: 59));
    expect(await service.list(TourCollection.sights, 'en'), isNotEmpty);
    expect(source.listCalls['Sights'], 1);
    now = now.add(const Duration(seconds: 1));
    await expectLater(
        service.list(TourCollection.sights, 'en'), throwsStateError);
    expect(source.listCalls['Sights'], 2);
  });

  test('refresh invalidates only the selected collection and signals listeners',
      () async {
    await service.list(TourCollection.sights, 'en');
    await service.list(TourCollection.parks, 'en');
    var signals = 0;
    service.refreshSignal(TourCollection.sights).addListener(() => signals++);
    service.refresh(TourCollection.sights);
    await service.list(TourCollection.sights, 'en');
    await service.list(TourCollection.parks, 'en');
    expect(signals, 1);
    expect(source.listCalls['Sights'], 2);
    expect(source.listCalls['Parks'], 1);
  });

  test('coalesces concurrent requests and does not cache failures', () async {
    final pending = Completer<List<Map<String, dynamic>>>();
    source.listResponses.add(pending.future);
    final first = service.list(TourCollection.sights, 'en');
    final second = service.list(TourCollection.sights, 'de');
    expect(source.listCalls['Sights'], 1);
    pending.complete(source.rows['Sights']!);
    expect(await first, isNotEmpty);
    expect(await second, isNotEmpty);

    service.refresh(TourCollection.sights);
    source.offline = true;
    await expectLater(
        service.list(TourCollection.sights, 'en'), throwsStateError);
    source.offline = false;
    expect(await service.list(TourCollection.sights, 'en'), isNotEmpty);
    expect(source.listCalls['Sights'], 3);
  });

  test('a refresh cannot be overwritten by an older in-flight request',
      () async {
    final oldRequest = Completer<List<Map<String, dynamic>>>();
    source.listResponses.add(oldRequest.future);
    final old = service.list(TourCollection.sights, 'en');
    service.refresh(TourCollection.sights);
    source.rows['Sights']!.first['title_en'] = 'updated';
    final fresh = await service.list(TourCollection.sights, 'en');
    oldRequest.complete([
      {...source.rows['Sights']!.first, 'title_en': 'outdated'},
    ]);
    expect((await old).first['title'], 'outdated');
    expect(fresh.first['title'], 'updated');
    expect((await service.list(TourCollection.sights, 'en')).first['title'],
        'updated');
    expect(source.listCalls['Sights'], 2);
  });

  test('callers cannot mutate cached records', () async {
    final first = await service.list(TourCollection.parks, 'en');
    first.first['title_en'] = 'mutated';
    first.clear();
    final second = await service.list(TourCollection.parks, 'en');
    expect(second.first['title'], source.rows['Parks']!.first['title_en']);
    expect(source.listCalls['Parks'], 1);
  });

  test('evicts the least recently used detail when the cache is full',
      () async {
    await service.get(TourCollection.sights, 'Sights1', 'en');
    await service.get(TourCollection.sights, 'Sights2', 'en');
    await service.get(TourCollection.sights, 'Sights1', 'de');
    await service.get(TourCollection.sights, 'Sights3', 'en');
    await service.get(TourCollection.sights, 'Sights2', 'en');
    expect(source.detailCalls, 4);
  });

  test('invalid records are discarded so a retry can fetch corrected data',
      () async {
    final original = source.rows['Hotels']!.first.remove('title_de');
    await expectLater(
        service.list(TourCollection.hotels, 'de'), throwsFormatException);
    source.rows['Hotels']!.first['title_de'] = original;
    expect(await service.list(TourCollection.hotels, 'de'), isNotEmpty);
    expect(source.listCalls['Hotels'], 2);
  });
}

class _CountingSource implements TourDataSource {
  _CountingSource() {
    final fixtures = makeTourFixtures();
    for (final collection in TourCollection.values) {
      final name = TourDataMapper.className(collection);
      rows[name] = fixtures[collection]!.map((record) {
        return {...record, 'objectId': '$name${record['id']}'};
      }).toList();
    }
  }

  final Map<String, List<Map<String, dynamic>>> rows = {};
  final Map<String, int> listCalls = {};
  final Queue<Future<List<Map<String, dynamic>>>> listResponses = Queue();
  int detailCalls = 0;
  bool offline = false;

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String className) {
    listCalls[className] = (listCalls[className] ?? 0) + 1;
    if (listResponses.isNotEmpty) return listResponses.removeFirst();
    if (offline) return Future.error(StateError('offline'));
    return Future.value(rows[className]!);
  }

  @override
  Future<Map<String, dynamic>> fetchById(String className, String objectId) {
    detailCalls++;
    if (offline) return Future.error(StateError('offline'));
    return Future.value(
      rows[className]!.singleWhere((row) => row['objectId'] == objectId),
    );
  }
}
