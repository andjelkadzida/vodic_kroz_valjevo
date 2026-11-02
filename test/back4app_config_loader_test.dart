import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/database_config/back4app_config_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetName = '.env';
  const validContents = 'KEY_APPLICATION_ID=test-app\n'
      'KEY_CLIENT_KEY=test-client\n'
      'KEY_PARSE_SERVER_URL=https://example.test/parse\n';

  test('loads the client settings from the .env asset', () async {
    final bundle = _TestAssetBundle({assetName: validContents});

    final config = await loadBack4AppConfig(bundle: bundle);

    expect(bundle.requests, [assetName]);
    expect(config.applicationId, 'test-app');
    expect(config.clientKey, 'test-client');
    expect(config.serverUrl, Uri.parse('https://example.test/parse'));
  });

  test('loads only the client settings from the default bundle', () async {
    final config = await loadBack4AppConfig();

    expect(config.applicationId, isNotEmpty);
    expect(config.clientKey, isNotEmpty);
    expect(config.serverUrl.hasAuthority, isTrue);
    expect(config.toEnvironment().keys.toSet(), {
      'KEY_APPLICATION_ID',
      'KEY_CLIENT_KEY',
      'KEY_PARSE_SERVER_URL',
    });
  });

  test('supports dotenv comments, quotes, exports, and known references',
      () async {
    final bundle = _TestAssetBundle({
      assetName: '# Client settings\n'
          'export KEY_APPLICATION_ID = "test-app" # comment\n'
          r'KEY_CLIENT_KEY="${KEY_APPLICATION_ID}-client"'
          '\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse\n',
    });

    final config = await loadBack4AppConfig(bundle: bundle);

    expect(config.applicationId, 'test-app');
    expect(config.clientKey, 'test-app-client');
  });

  test('preserves literal variable references in single-quoted values',
      () async {
    final bundle = _TestAssetBundle({
      assetName: 'KEY_APPLICATION_ID=test-app\n'
          r"KEY_CLIENT_KEY='private$literal'"
          '\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse\n',
    });

    expect((await loadBack4AppConfig(bundle: bundle)).clientKey,
        r'private$literal');
  });

  test('rejects malformed entries, duplicate keys and invalid references',
      () async {
    final invalidEntries = [
      'KEY_APPLICATION_ID\nKEY_CLIENT_KEY=test-client\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse',
      'KEY APPLICATION_ID=test-app\nKEY_CLIENT_KEY=test-client\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse',
      'exportKEY_APPLICATION_ID=test-app\nKEY_CLIENT_KEY=test-client\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse',
      'KEY_APPLICATION_ID="unterminated\nKEY_CLIENT_KEY=test-client\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse',
      'KEY_APPLICATION_ID="test-app" trailing\nKEY_CLIENT_KEY=test-client\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse',
      '$validContents\nKEY_APPLICATION_ID=another-app',
      'KEY_APPLICATION_ID=test-app\n'
          r'KEY_CLIENT_KEY=prefix$UNKNOWN'
          '\nKEY_PARSE_SERVER_URL=https://example.test/parse',
      'KEY_APPLICATION_ID=test-app\n'
          r'KEY_CLIENT_KEY=${KEY_APPLICATION_ID'
          '\nKEY_PARSE_SERVER_URL=https://example.test/parse',
    ];
    for (final contents in invalidEntries) {
      final bundle = _TestAssetBundle({assetName: contents});
      await expectLater(
          loadBack4AppConfig(bundle: bundle), throwsFormatException);
    }
  });

  test('rejects unexpected settings instead of silently filtering them',
      () async {
    const contents = '$validContents'
        'SERVER_ONLY_SECRET=private-test-value\n';
    expect(contents, contains('private-test-value'));
    await expectLater(
      loadBack4AppConfig(bundle: _TestAssetBundle({assetName: contents})),
      throwsFormatException,
    );
  });

  test('rejects missing and empty client settings', () async {
    for (final contents in [
      'KEY_APPLICATION_ID=test-app\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse\n',
      'KEY_APPLICATION_ID=test-app\nKEY_CLIENT_KEY=\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse\n',
      "KEY_APPLICATION_ID=test-app\nKEY_CLIENT_KEY=''\n"
          'KEY_PARSE_SERVER_URL=https://example.test/parse\n',
      'KEY_APPLICATION_ID=test-app\nKEY_CLIENT_KEY=""\n'
          'KEY_PARSE_SERVER_URL=https://example.test/parse\n',
    ]) {
      final bundle = _TestAssetBundle({assetName: contents});
      await expectLater(loadBack4AppConfig(bundle: bundle), throwsStateError);
    }
  });

  test('reports invalid server URLs and missing assets', () async {
    final invalidUrl = _TestAssetBundle({
      assetName: 'KEY_APPLICATION_ID=test-app\n'
          'KEY_CLIENT_KEY=test-client\n'
          'KEY_PARSE_SERVER_URL=http://example.test/parse\n',
    });
    await expectLater(loadBack4AppConfig(bundle: invalidUrl), throwsStateError);
    await expectLater(
      loadBack4AppConfig(bundle: _TestAssetBundle({})),
      throwsA(isA<FlutterError>()),
    );
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  _TestAssetBundle(this.contents);

  final Map<String, String> contents;
  final List<String> requests = [];

  @override
  Future<ByteData> load(String key) async {
    requests.add(key);
    final content = contents[key];
    if (content == null) throw FlutterError('Asset not found: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  }
}
