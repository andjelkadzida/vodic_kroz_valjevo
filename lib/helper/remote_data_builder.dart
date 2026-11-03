import 'package:flutter/material.dart';

import 'connection_problem_view.dart';
import 'internet_connectivity.dart';
import '../localization/supported_languages.dart';

class RemoteDataBuilder<T> extends StatefulWidget {
  const RemoteDataBuilder({
    Key? key,
    required this.queryKey,
    required this.load,
    required this.onData,
    this.standalone = false,
    this.refreshSignal,
    this.onRetry,
    this.networkStatus,
  }) : super(key: key);

  final Object queryKey;
  final Future<T> Function() load;
  final Widget Function(T data) onData;
  final bool standalone;
  final Listenable? refreshSignal;
  final VoidCallback? onRetry;
  final NetworkStatusMonitor? networkStatus;

  @override
  State<RemoteDataBuilder<T>> createState() => _RemoteDataBuilderState<T>();
}

class _RemoteDataBuilderState<T> extends State<RemoteDataBuilder<T>> {
  late Future<T> _future;
  late NetworkStatusMonitor _networkStatus;
  late NetworkStatus _lastNetworkStatus;
  int _requestRevision = 0;
  bool _requestPending = false;
  bool _waitingForConnection = false;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _networkStatus = widget.networkStatus ?? NetworkStatusMonitor.instance;
    _lastNetworkStatus = _networkStatus.status;
    _future = _load();
    widget.refreshSignal?.addListener(_reload);
    _networkStatus.addListener(_onNetworkStatusChanged);
  }

  @override
  void didUpdateWidget(covariant RemoteDataBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      oldWidget.refreshSignal?.removeListener(_reload);
      widget.refreshSignal?.addListener(_reload);
    }
    final networkStatus = widget.networkStatus ?? NetworkStatusMonitor.instance;
    if (_networkStatus != networkStatus) {
      _networkStatus.removeListener(_onNetworkStatusChanged);
      _networkStatus = networkStatus;
      _lastNetworkStatus = networkStatus.status;
      _waitingForConnection =
          _requestPending && networkStatus.status == NetworkStatus.disconnected;
      _networkStatus.addListener(_onNetworkStatusChanged);
    }
    if (oldWidget.queryKey != widget.queryKey) {
      _future = _load();
    }
  }

  @override
  void dispose() {
    _requestRevision++;
    _networkStatus.removeListener(_onNetworkStatusChanged);
    widget.refreshSignal?.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<T> _load() {
    final revision = ++_requestRevision;
    _requestPending = true;
    _lastError = null;
    _waitingForConnection = _networkStatus.status == NetworkStatus.disconnected;
    return Future<T>.sync(widget.load).then(
      (data) {
        if (revision == _requestRevision) {
          _requestPending = false;
          _waitingForConnection = false;
        }
        return data;
      },
      onError: (Object error, StackTrace stackTrace) {
        if (revision == _requestRevision) {
          _requestPending = false;
          _lastError = error;
          _waitingForConnection =
              _networkStatus.status == NetworkStatus.disconnected &&
                  isPossibleConnectionFailure(error);
        }
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
  }

  void _onNetworkStatusChanged() {
    if (!mounted) return;
    final previous = _lastNetworkStatus;
    final current = _networkStatus.status;
    _lastNetworkStatus = current;
    final error = _lastError;
    if (current == NetworkStatus.disconnected &&
        (_requestPending ||
            (error != null && isPossibleConnectionFailure(error)))) {
      _waitingForConnection = true;
    }
    if (previous == NetworkStatus.disconnected &&
        current == NetworkStatus.connected &&
        _waitingForConnection) {
      _waitingForConnection = false;
      _retry();
      return;
    }
    setState(() {});
  }

  void _retry() {
    final onRetry = widget.onRetry;
    if (onRetry == null) {
      _reload();
    } else {
      onRetry();
      if (widget.refreshSignal == null) _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        Widget content;
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_networkStatus.status == NetworkStatus.disconnected) {
            content = ConnectionProblemView(
              disconnected: true,
              onRetry: _retry,
            );
          } else {
            content = Center(
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Semantics(
                    tooltip: localization(context).loading,
                    child: CircularProgressIndicator(
                      semanticsLabel: localization(context).loading,
                    ),
                  ),
                ),
              ),
            );
          }
        } else if (snapshot.hasError &&
            isPossibleConnectionFailure(snapshot.error!)) {
          content = ConnectionProblemView(
            disconnected: _networkStatus.status == NetworkStatus.disconnected,
            onRetry: _retry,
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            (snapshot.data is List && (snapshot.data as List).isEmpty)) {
          content = Center(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        snapshot.hasError
                            ? localization(context).errorLoadingData
                            : localization(context).noDataAvailable,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _retry,
                      tooltip: MaterialLocalizations.of(context)
                          .refreshIndicatorSemanticLabel,
                      icon: Icon(
                        Icons.refresh,
                        semanticLabel: MaterialLocalizations.of(context)
                            .refreshIndicatorSemanticLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return widget.onData(snapshot.data as T);
        }

        if (widget.standalone) {
          return Scaffold(appBar: AppBar(), body: content);
        }
        return content;
      },
    );
  }
}
