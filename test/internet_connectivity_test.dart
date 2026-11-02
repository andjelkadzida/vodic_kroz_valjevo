import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vodic_kroz_valjevo/helper/internet_connectivity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  var status = <String>['none'];

  setUp(() {
    status = ['none'];
    messenger.setMockMethodCallHandler(channel, (_) async => status);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('recognizes offline and online connectivity lists', () async {
    expect(await checkInitialInternetConnection(), isFalse);
    status = ['wifi'];
    expect(await checkInitialInternetConnection(), isTrue);
    status = ['none', 'mobile'];
    expect(await checkInitialInternetConnection(), isTrue);
    status = [];
    expect(await checkInitialInternetConnection(), isFalse);
  });

  test('maps connectivity change events correctly', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final values = hasInternetConnection(changes: controller.stream).toList();
    controller.add([ConnectivityResult.none]);
    controller.add([ConnectivityResult.wifi]);
    await controller.close();
    expect(await values, [false, true]);
  });
}
