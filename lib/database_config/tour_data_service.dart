import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../helper/internet_connectivity.dart';
import 'tour_data_mapper.dart';

export 'tour_data_mapper.dart';

abstract class TourDataSource {
  Future<List<Map<String, dynamic>>> fetchAll(String className);

  Future<Map<String, dynamic>> fetchById(String className, String objectId);
}

class ParseTourDataSource implements TourDataSource {
  ParseTourDataSource({this.client, this.pageSize = 100})
      : assert(pageSize > 0);

  final ParseClient? client;
  final int pageSize;

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String className) async {
    final records = <Map<String, dynamic>>[];
    var offset = 0;
    while (true) {
      final query = QueryBuilder<ParseObject>(
        ParseObject(className, client: client),
      )
        ..setLimit(pageSize)
        ..setAmountToSkip(offset)
        ..orderByAscending('createdAt')
        ..orderByAscending('objectId');
      final response = await query.query<ParseObject>();
      _checkResponse(response, className);
      final page = _objects(response, className);
      records.addAll(page.map((object) => object.toJson()));
      if (page.length < pageSize) return records;
      offset += page.length;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchById(
      String className, String objectId) async {
    if (objectId.isEmpty) {
      throw ArgumentError.value(objectId, 'objectId', 'Must not be empty.');
    }
    final response =
        await ParseObject(className, client: client).getObject(objectId);
    _checkResponse(response, className);
    final objects = _objects(response, className);
    if (objects.length != 1) {
      throw StateError(
        'Back4App returned ${objects.length} records for $className/$objectId.',
      );
    }
    return objects.single.toJson();
  }

  void _checkResponse(ParseResponse response, String className) {
    if (!response.success) {
      final error = response.error;
      throw Back4AppDataException(
        'Unable to load $className: ${error?.message ?? 'unknown error'}',
        code: error?.code,
      );
    }
  }

  List<ParseObject> _objects(ParseResponse response, String className) {
    final objects = <ParseObject>[];
    for (final item in response.results ?? const []) {
      if (item is! ParseObject) {
        throw FormatException('Invalid Back4App response for $className.');
      }
      objects.add(item);
    }
    return objects;
  }
}

class Back4AppDataException implements Exception, PossibleConnectionFailure {
  const Back4AppDataException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  bool get mayBeConnectionFailure =>
      code == null ||
      code == ParseError.otherCause ||
      code == ParseError.connectionFailed;

  @override
  String toString() => 'Back4AppDataException: $message';
}

class CachedTourDataSource implements TourDataSource {
  CachedTourDataSource(
    this._source, {
    this.lifetime = const Duration(minutes: 5),
    DateTime Function()? clock,
    this.maxDetails = 128,
  })  : assert(lifetime > Duration.zero),
        assert(maxDetails > 0),
        _clock = clock ?? DateTime.now;

  final TourDataSource _source;
  final Duration lifetime;
  final int maxDetails;
  final DateTime Function() _clock;
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _collections = {};
  final LinkedHashMap<_RecordKey, _CacheEntry<Map<String, dynamic>>> _details =
      LinkedHashMap();
  final Map<String, Future<List<Map<String, dynamic>>>> _pendingCollections =
      {};
  final Map<_RecordKey, Future<Map<String, dynamic>>> _pendingDetails = {};
  final Map<String, int> _generations = {};

  void invalidate(String className) {
    _generations[className] = (_generations[className] ?? 0) + 1;
    _collections.remove(className);
    _details.removeWhere((key, _) => key.className == className);
    _pendingCollections.remove(className);
    _pendingDetails.removeWhere((key, _) => key.className == className);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String className) async {
    final cached = _collections[className];
    if (cached != null && _clock().isBefore(cached.expiresAt)) {
      return _copyRecords(cached.value);
    }
    _collections.remove(className);

    final pending = _pendingCollections[className];
    if (pending != null) return _copyRecords(await pending);

    final generation = _generations[className] ?? 0;
    final request = _source.fetchAll(className);
    _pendingCollections[className] = request;
    try {
      final records = await request;
      if ((_generations[className] ?? 0) == generation) {
        _collections[className] = _CacheEntry(
          records
              .map((record) => Map<String, dynamic>.unmodifiable(record))
              .toList(),
          _clock().add(lifetime),
        );
      }
      return _copyRecords(records);
    } finally {
      if (identical(_pendingCollections[className], request)) {
        _pendingCollections.remove(className);
      }
    }
  }

  @override
  Future<Map<String, dynamic>> fetchById(
      String className, String objectId) async {
    final collection = _collections[className];
    if (collection != null && _clock().isBefore(collection.expiresAt)) {
      for (final record in collection.value) {
        if (record['objectId'] == objectId) {
          return Map<String, dynamic>.from(record);
        }
      }
    }

    final key = _RecordKey(className, objectId);
    final cached = _details.remove(key);
    if (cached != null && _clock().isBefore(cached.expiresAt)) {
      _details[key] = cached;
      return Map<String, dynamic>.from(cached.value);
    }

    final pending = _pendingDetails[key];
    if (pending != null) return Map<String, dynamic>.from(await pending);

    final generation = _generations[className] ?? 0;
    final request = _source.fetchById(className, objectId);
    _pendingDetails[key] = request;
    try {
      final record = await request;
      if ((_generations[className] ?? 0) == generation) {
        _details.remove(key);
        if (_details.length >= maxDetails) _details.remove(_details.keys.first);
        _details[key] = _CacheEntry(
          Map<String, dynamic>.unmodifiable(record),
          _clock().add(lifetime),
        );
      }
      return Map<String, dynamic>.from(record);
    } finally {
      if (identical(_pendingDetails[key], request)) {
        _pendingDetails.remove(key);
      }
    }
  }

  List<Map<String, dynamic>> _copyRecords(List<Map<String, dynamic>> records) =>
      records.map((record) => Map<String, dynamic>.from(record)).toList();
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.expiresAt);

  final T value;
  final DateTime expiresAt;
}

class _RecordKey {
  const _RecordKey(this.className, this.objectId);

  final String className;
  final String objectId;

  @override
  bool operator ==(Object other) =>
      other is _RecordKey &&
      other.className == className &&
      other.objectId == objectId;

  @override
  int get hashCode => Object.hash(className, objectId);
}

class TourDataService {
  TourDataService(
    TourDataSource source, {
    Duration cacheLifetime = const Duration(minutes: 5),
    DateTime Function()? clock,
    int maxCachedDetails = 128,
  }) : _source = CachedTourDataSource(
          source,
          lifetime: cacheLifetime,
          clock: clock,
          maxDetails: maxCachedDetails,
        );

  static final TourDataService instance =
      TourDataService(ParseTourDataSource());

  final CachedTourDataSource _source;
  final Map<TourCollection, ValueNotifier<int>> _refreshSignals = {
    for (final collection in TourCollection.values)
      collection: ValueNotifier<int>(0),
  };

  Listenable refreshSignal(TourCollection collection) =>
      _refreshSignals[collection]!;

  void refresh(TourCollection collection) {
    _source.invalidate(TourDataMapper.className(collection));
    _refreshSignals[collection]!.value++;
  }

  Future<List<Map<String, dynamic>>> list(
      TourCollection collection, String locale) async {
    final className = TourDataMapper.className(collection);
    final records = await _source.fetchAll(className);
    try {
      return records
          .map((record) => TourDataMapper.forLocale(collection, record, locale))
          .toList();
    } on FormatException {
      _source.invalidate(className);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(
      TourCollection collection, String objectId, String locale) async {
    final className = TourDataMapper.className(collection);
    final record = await _source.fetchById(className, objectId);
    try {
      return TourDataMapper.forLocale(collection, record, locale);
    } on FormatException {
      _source.invalidate(className);
      rethrow;
    }
  }
}
