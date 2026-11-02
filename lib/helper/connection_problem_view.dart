import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import 'internet_connectivity.dart';

String networkSettingsGuidance(BuildContext context) {
  final messages = localization(context);
  return defaultTargetPlatform == TargetPlatform.iOS
      ? messages.networkSettingsIosHint
      : messages.networkSettingsHint;
}

Future<void> openNetworkSettings(BuildContext context) async {
  try {
    await AppSettings.openAppSettings(type: AppSettingsType.wireless);
  } catch (error, stackTrace) {
    if (!context.mounted) {
      debugPrint('Opening network settings failed: ${error.runtimeType}');
      return;
    }
    await showOperationFailure(
      context,
      error: error,
      stackTrace: stackTrace,
      operation: 'Opening network settings',
      message: (context) => localization(context).networkSettingsFailed,
      hint: networkSettingsGuidance,
    );
  }
}

Future<void> showOperationFailure(
  BuildContext context, {
  required Object error,
  required StackTrace stackTrace,
  required String operation,
  required String Function(BuildContext) message,
  String Function(BuildContext)? hint,
}) async {
  debugPrint('$operation failed: ${error.runtimeType}');
  if (!context.mounted) return;
  if (Navigator.maybeOf(context) == null) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: operation,
    ));
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        scrollable: true,
        title: Text(message(dialogContext)),
        content: hint == null ? null : Text(hint(dialogContext)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(localization(dialogContext).ok),
          ),
        ],
      );
    },
  );
}

Future<void> showConnectionProblemDialog(
  BuildContext context, {
  required bool disconnected,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final messages = localization(dialogContext);
      final height = (MediaQuery.sizeOf(dialogContext).height - 32)
          .clamp(0.0, double.infinity);
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480, maxHeight: height),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ConnectionAwareFailure(
                  initialDisconnected: disconnected,
                  onReconnected: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: const Color.fromRGBO(11, 20, 32, 1),
                ),
                child: Text(messages.close, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ConnectionProblemView extends StatelessWidget {
  const ConnectionProblemView({
    Key? key,
    required this.disconnected,
    this.onRetry,
    this.compact = false,
  }) : super(key: key);

  final bool disconnected;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final messages = localization(context);
    final message = disconnected
        ? messages.noInternetConnection
        : messages.connectionProblem;
    final hint = networkSettingsGuidance(context);
    const color = Color.fromRGBO(11, 20, 32, 1);
    return Center(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(compact ? 4 : 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(compact ? 8 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!compact) ...[
                    const ExcludeSemantics(
                      child: Icon(Icons.wifi_off_outlined, size: 64),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (!compact ||
                      defaultTargetPlatform == TargetPlatform.iOS) ...[
                    const SizedBox(height: 8),
                    Text(hint, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ElevatedButton(
                        onPressed: () => openNetworkSettings(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          messages.openSettings,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (onRetry != null)
                        TextButton(
                          onPressed: onRetry,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            foregroundColor: color,
                          ),
                          child: Text(
                            messages.retryConnection,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConnectionAwareFailure extends StatefulWidget {
  const ConnectionAwareFailure({
    Key? key,
    this.onRetry,
    this.onReconnected,
    this.initialDisconnected,
    this.compact = false,
    this.networkStatus,
  }) : super(key: key);

  final VoidCallback? onRetry;
  final VoidCallback? onReconnected;
  final bool? initialDisconnected;
  final bool compact;
  final NetworkStatusMonitor? networkStatus;

  @override
  State<ConnectionAwareFailure> createState() => _ConnectionAwareFailureState();
}

class _ConnectionAwareFailureState extends State<ConnectionAwareFailure> {
  late NetworkStatusMonitor _networkStatus;
  late NetworkStatus _lastStatus;

  @override
  void initState() {
    super.initState();
    _attach(widget.networkStatus ?? NetworkStatusMonitor.instance);
  }

  void _attach(NetworkStatusMonitor monitor) {
    _networkStatus = monitor;
    _lastStatus = widget.initialDisconnected == true
        ? NetworkStatus.disconnected
        : monitor.status;
    monitor.addListener(_onStatusChanged);
    if (widget.initialDisconnected != null) {
      unawaited(_refreshInitialStatus(monitor));
    }
  }

  Future<void> _refreshInitialStatus(NetworkStatusMonitor monitor) async {
    await monitor.refresh();
    if (!mounted || monitor != _networkStatus) return;
    if (_lastStatus == NetworkStatus.disconnected &&
        monitor.status == NetworkStatus.connected) {
      _lastStatus = NetworkStatus.connected;
      (widget.onReconnected ?? widget.onRetry)?.call();
    }
  }

  @override
  void didUpdateWidget(covariant ConnectionAwareFailure oldWidget) {
    super.didUpdateWidget(oldWidget);
    final monitor = widget.networkStatus ?? NetworkStatusMonitor.instance;
    if (monitor != _networkStatus) {
      _networkStatus.removeListener(_onStatusChanged);
      _attach(monitor);
    }
  }

  void _onStatusChanged() {
    if (!mounted) return;
    final previous = _lastStatus;
    _lastStatus = _networkStatus.status;
    if (previous == NetworkStatus.disconnected &&
        _lastStatus == NetworkStatus.connected) {
      (widget.onReconnected ?? widget.onRetry)?.call();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _networkStatus.removeListener(_onStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionProblemView(
      disconnected: _networkStatus.status == NetworkStatus.disconnected ||
          (_networkStatus.status == NetworkStatus.unknown &&
              widget.initialDisconnected == true),
      onRetry: widget.onRetry,
      compact: widget.compact,
    );
  }
}
