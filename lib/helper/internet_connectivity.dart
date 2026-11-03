import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

/// Reports network-interface availability, not guaranteed internet access.
Future<bool> checkInitialInternetConnection() async {
  final results = await Connectivity().checkConnectivity();
  return _isConnected(results);
}

/// Emits network-interface changes, which may not detect captive portals.
Stream<bool> hasInternetConnection(
        {Stream<List<ConnectivityResult>>? changes}) =>
    (changes ?? Connectivity().onConnectivityChanged).map(_isConnected);

bool _isConnected(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

enum NetworkStatus { unknown, connected, disconnected, error }

abstract class PossibleConnectionFailure {
  bool get mayBeConnectionFailure;
}

bool isPossibleConnectionFailure(Object error) =>
    error is SocketException ||
    error is HttpException ||
    error is TimeoutException ||
    (error is PossibleConnectionFailure && error.mayBeConnectionFailure);

class NetworkStatusMonitor extends ChangeNotifier with WidgetsBindingObserver {
  NetworkStatusMonitor({
    Future<bool> Function()? checkConnection,
    Stream<bool> Function()? connectionChanges,
  })  : _checkConnection = checkConnection ?? checkInitialInternetConnection,
        _connectionChanges = connectionChanges ?? hasInternetConnection;

  static final NetworkStatusMonitor instance = NetworkStatusMonitor();

  final Future<bool> Function() _checkConnection;
  final Stream<bool> Function() _connectionChanges;
  final Map<VoidCallback, int> _listeners = {};
  StreamSubscription<bool>? _subscription;
  NetworkStatus _status = NetworkStatus.unknown;
  bool _active = false;
  int _revision = 0;

  NetworkStatus get status => _status;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listeners[listener] = (_listeners[listener] ?? 0) + 1;
    if (!_active) _start();
  }

  @override
  void removeListener(VoidCallback listener) {
    final count = _listeners[listener];
    super.removeListener(listener);
    if (count == null) return;
    if (count == 1) {
      _listeners.remove(listener);
    } else {
      _listeners[listener] = count - 1;
    }
    if (_listeners.isEmpty) _stop();
  }

  void _start() {
    _active = true;
    WidgetsBinding.instance.addObserver(this);
    unawaited(refresh());
    try {
      _subscription = _connectionChanges().listen(
        (connected) {
          if (!_active) return;
          _revision++;
          _update(connected);
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Connectivity monitoring failed: ${error.runtimeType}');
          if (!_active) return;
          _revision++;
          _setStatus(NetworkStatus.error);
        },
        onDone: () {
          if (!_active) return;
          debugPrint('Connectivity monitoring ended unexpectedly.');
          _revision++;
          _setStatus(NetworkStatus.error);
        },
      );
    } catch (error) {
      debugPrint('Connectivity monitoring failed: ${error.runtimeType}');
    }
  }

  Future<void> refresh() async {
    final revision = ++_revision;
    try {
      final connected = await _checkConnection();
      if (_active && revision == _revision) _update(connected);
    } catch (error) {
      debugPrint('Connectivity check failed: ${error.runtimeType}');
      if (_active && revision == _revision) {
        _setStatus(NetworkStatus.error);
      }
    }
  }

  void _update(bool connected) => _setStatus(
        connected ? NetworkStatus.connected : NetworkStatus.disconnected,
      );

  void _setStatus(NetworkStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  void _stop() {
    if (!_active) return;
    _active = false;
    _revision++;
    WidgetsBinding.instance.removeObserver(this);
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel().catchError((Object error) {
        debugPrint('Connectivity monitoring stopped: ${error.runtimeType}');
      }));
    }
    _status = NetworkStatus.unknown;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _active) {
      unawaited(refresh());
    }
  }

  @override
  void dispose() {
    _listeners.clear();
    _stop();
    super.dispose();
  }
}
