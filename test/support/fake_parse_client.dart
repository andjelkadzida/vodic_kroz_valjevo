import 'dart:convert';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_mapper.dart';

import 'tour_fixtures.dart';

class FakeParseClient extends ParseClient {
  FakeParseClient(TourFixtureData fixtures) {
    for (final collection in TourCollection.values) {
      final name = TourDataMapper.className(collection);
      records[name] = fixtures[collection]!.map((row) {
        return {
          ...row,
          'sourceId': row['id'],
          'objectId': '$name${row['id']}',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        }..remove('id');
      }).toList();
    }
  }

  final Map<String, List<Map<String, dynamic>>> records = {};
  final List<Uri> requests = [];
  final Set<String> emptyClasses = {};
  String? forbiddenClass;

  @override
  Future<ParseNetworkResponse> get(
    String path, {
    ParseNetworkOptions? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    final uri = Uri.parse(path);
    requests.add(uri);
    final index = uri.pathSegments.indexOf('classes');
    final name = uri.pathSegments[index + 1];
    if (name == forbiddenClass) {
      return ParseNetworkResponse(
        statusCode: 403,
        data: jsonEncode({'code': 119, 'error': 'permission denied'}),
      );
    }
    final rows =
        emptyClasses.contains(name) ? <Map<String, dynamic>>[] : records[name]!;
    if (uri.pathSegments.length > index + 2) {
      final id = uri.pathSegments[index + 2];
      final matches = rows.where((row) => row['objectId'] == id).toList();
      if (matches.isEmpty) {
        return ParseNetworkResponse(
          statusCode: 404,
          data: jsonEncode({'code': 101, 'error': 'object not found'}),
        );
      }
      return ParseNetworkResponse(
          statusCode: 200, data: jsonEncode(matches.single));
    }

    final skip = int.parse(uri.queryParameters['skip'] ?? '0');
    final limit = int.parse(uri.queryParameters['limit'] ?? '100');
    final page = rows.skip(skip).take(limit).toList();
    return ParseNetworkResponse(
        statusCode: 200, data: jsonEncode({'results': page}));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
