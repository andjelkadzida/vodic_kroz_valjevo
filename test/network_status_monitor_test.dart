import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:vodic_kroz_valjevo/database_config/tour_data_service.dart';
import 'package:vodic_kroz_valjevo/helper/internet_connectivity.dart';
import 'package:vodic_kroz_valjevo/pages/bug_report.dart';

void main() {
  testWidgets('a connectivity event wins over a stale initial check',
      (tester) async {
    final initial = Completer<bool>();
    final events = StreamController<bool>.broadcast(sync: true);
    final monitor = NetworkStatusMonitor(
      checkConnection: () => initial.future,
      connectionChanges: () => events.stream,
    );
    addTearDown(() async {
      monitor.dispose();
      await events.close();
    });
    final observed = <NetworkStatus>[];
    void listener() => observed.add(monitor.status);
    monitor.addListener(listener);

    events.add(false);
    initial.complete(true);
    await tester.pump();
    expect(monitor.status, NetworkStatus.disconnected);
    expect(observed, [NetworkStatus.disconnected]);

    monitor.removeListener(listener);
  });

  testWidgets('multiple listeners share one connectivity subscription',
      (tester) async {
    var checks = 0;
    var subscriptions = 0;
    var cancellations = 0;
    final events = StreamController<bool>.broadcast(
      sync: true,
      onListen: () => subscriptions++,
      onCancel: () => cancellations++,
    );
    final monitor = NetworkStatusMonitor(
      checkConnection: () async {
        checks++;
        return true;
      },
      connectionChanges: () => events.stream,
    );
    addTearDown(() async {
      monitor.dispose();
      await events.close();
    });
    void first() {}
    void second() {}
    monitor.addListener(first);
    monitor.addListener(second);
    await tester.pump();
    expect(checks, 1);
    expect(subscriptions, 1);
    monitor.removeListener(first);
    expect(cancellations, 0);
    monitor.removeListener(second);
    await tester.pump();
    expect(cancellations, 1);
    expect(monitor.status, NetworkStatus.unknown);
  });

  testWidgets('stops monitoring when a listener removes itself during an event',
      (tester) async {
    var subscriptions = 0;
    var cancellations = 0;
    final events = StreamController<bool>.broadcast(
      sync: true,
      onListen: () => subscriptions++,
      onCancel: () => cancellations++,
    );
    final monitor = NetworkStatusMonitor(
      checkConnection: () async => true,
      connectionChanges: () => events.stream,
    );
    addTearDown(() async {
      monitor.dispose();
      await events.close();
    });
    late VoidCallback listener;
    listener = () {
      if (monitor.status == NetworkStatus.disconnected) {
        monitor.removeListener(listener);
      }
    };
    monitor.addListener(listener);
    await tester.pump();
    events.add(false);
    await tester.pump();
    expect(cancellations, 1);
    expect(monitor.status, NetworkStatus.unknown);

    monitor.addListener(listener);
    await tester.pump();
    expect(subscriptions, 2);
    expect(monitor.status, NetworkStatus.connected);
    monitor.removeListener(listener);
  });

  testWidgets('tracks repeated registrations of the same listener',
      (tester) async {
    final events = StreamController<bool>.broadcast(sync: true);
    final monitor = NetworkStatusMonitor(
      checkConnection: () async => true,
      connectionChanges: () => events.stream,
    );
    addTearDown(() async {
      monitor.dispose();
      await events.close();
    });
    var calls = 0;
    void listener() => calls++;
    monitor.addListener(listener);
    monitor.addListener(listener);
    await tester.pump();
    monitor.removeListener(listener);
    calls = 0;
    events.add(false);
    await tester.pump();
    expect(calls, 1);
    expect(monitor.status, NetworkStatus.disconnected);
    monitor.removeListener(listener);
    expect(monitor.status, NetworkStatus.unknown);
  });

  testWidgets('rechecks connectivity when the app resumes', (tester) async {
    var connected = false;
    var checks = 0;
    final events = StreamController<bool>.broadcast(sync: true);
    final monitor = NetworkStatusMonitor(
      checkConnection: () async {
        checks++;
        return connected;
      },
      connectionChanges: () => events.stream,
    );
    addTearDown(() async {
      monitor.dispose();
      await events.close();
    });
    void listener() {}
    monitor.addListener(listener);
    await tester.pump();
    expect(monitor.status, NetworkStatus.disconnected);

    connected = true;
    monitor.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    expect(monitor.status, NetworkStatus.connected);
    expect(checks, 2);

    monitor.removeListener(listener);
    expect(monitor.status, NetworkStatus.unknown);
  });

  testWidgets('reports connectivity check failures instead of assuming online',
      (tester) async {
    final events = StreamController<bool>.broadcast(sync: true);
    final monitor = NetworkStatusMonitor(
      checkConnection: () async => throw StateError('unavailable'),
      connectionChanges: () => events.stream,
    );
    addTearDown(() async {
      monitor.dispose();
      await events.close();
    });
    void listener() {}
    monitor.addListener(listener);
    await tester.pump();
    expect(monitor.status, NetworkStatus.error);
    monitor.removeListener(listener);
  });

  testWidgets('reports stream errors and recovers on a later update',
      (tester) async {
    final events = StreamController<bool>.broadcast(sync: true);
    final monitor = NetworkStatusMonitor(
      checkConnection: () async => true,
      connectionChanges: () => events.stream,
    );
    addTearDown(() async {
      monitor.dispose();
      await events.close();
    });
    void listener() {}
    monitor.addListener(listener);
    await tester.pump();
    expect(monitor.status, NetworkStatus.connected);
    events.addError(StateError('monitor unavailable'));
    await tester.pump();
    expect(monitor.status, NetworkStatus.error);
    events.add(false);
    await tester.pump();
    expect(monitor.status, NetworkStatus.disconnected);
    monitor.removeListener(listener);
  });

  testWidgets('reports an unexpectedly closed connectivity stream',
      (tester) async {
    final events = StreamController<bool>.broadcast(sync: true);
    final monitor = NetworkStatusMonitor(
      checkConnection: () async => true,
      connectionChanges: () => events.stream,
    );
    addTearDown(monitor.dispose);
    void listener() {}
    monitor.addListener(listener);
    await tester.pump();
    expect(monitor.status, NetworkStatus.connected);
    await events.close();
    await tester.pump();
    expect(monitor.status, NetworkStatus.error);
    monitor.removeListener(listener);
  });

  test('distinguishes potential network failures from data and server errors',
      () {
    expect(
        isPossibleConnectionFailure(const SocketException('offline')), isTrue);
    expect(isPossibleConnectionFailure(TimeoutException('timed out')), isTrue);
    expect(
      isPossibleConnectionFailure(
        const Back4AppDataException('network', code: ParseError.otherCause),
      ),
      isTrue,
    );
    expect(
      isPossibleConnectionFailure(
        const Back4AppDataException('forbidden', code: 119),
      ),
      isFalse,
    );
    expect(isPossibleConnectionFailure(const BugReportException(119)), isFalse);
    expect(
      isPossibleConnectionFailure(
        const BugReportException(ParseError.connectionFailed),
      ),
      isTrue,
    );
    expect(isPossibleConnectionFailure(const FormatException('bad data')),
        isFalse);
  });
}
