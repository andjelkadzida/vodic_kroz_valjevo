import 'package:flutter/material.dart';

import '../localization/supported_languages.dart';
import 'connection_problem_view.dart';
import 'internet_connectivity.dart';

ImageProvider<Object> tourImageProvider(String image, {int? cacheWidth}) {
  if (cacheWidth != null && cacheWidth <= 0) {
    throw ArgumentError.value(cacheWidth, 'cacheWidth', 'Must be positive.');
  }
  final uri = Uri.tryParse(image);
  final ImageProvider<Object> provider;
  if (uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty) {
    provider = NetworkImage(image);
  } else {
    provider = AssetImage(image);
  }
  return ResizeImage.resizeIfNeeded(cacheWidth, null, provider);
}

Widget tourImageLoadingBuilder(
    BuildContext context, Widget child, ImageChunkEvent? progress) {
  if (progress == null) return child;
  final total = progress.expectedTotalBytes;
  return Center(
    child: CircularProgressIndicator(
      value: total != null && total > 0
          ? progress.cumulativeBytesLoaded / total
          : null,
      semanticsLabel: localization(context).loading,
    ),
  );
}

Widget tourImageErrorBuilder(
  BuildContext context,
  Object error,
  StackTrace? stackTrace, {
  VoidCallback? onRetry,
}) {
  return TourImageFailure(
    error: error,
    onRetry: onRetry,
    compact: true,
  );
}

Future<void> retryTourImage({
  required BuildContext context,
  required String image,
  required VoidCallback onEvicted,
  int? cacheWidth,
}) =>
    retryImageProviders(
      context: context,
      providers: () => [tourImageProvider(image, cacheWidth: cacheWidth)],
      onEvicted: onEvicted,
    );

Future<void> retryImageProviders({
  required BuildContext context,
  required Iterable<ImageProvider> Function() providers,
  required VoidCallback onEvicted,
}) async {
  try {
    await Future.wait(providers().map((provider) => provider.evict()));
    if (context.mounted) onEvicted();
  } catch (error, stackTrace) {
    if (!context.mounted) {
      debugPrint('Image retry failed: ${error.runtimeType}');
      return;
    }
    await showOperationFailure(
      context,
      error: error,
      stackTrace: stackTrace,
      operation: 'Image retry',
      message: (context) => localization(context).errorLoadingData,
    );
  }
}

class TourImage extends StatefulWidget {
  const TourImage({
    Key? key,
    required this.image,
    this.cacheWidth,
    this.width,
    this.fit,
    this.semanticLabel,
  }) : super(key: key);

  final String image;
  final int? cacheWidth;
  final double? width;
  final BoxFit? fit;
  final String? semanticLabel;

  @override
  State<TourImage> createState() => _TourImageState();
}

class _TourImageState extends State<TourImage> {
  int _revision = 0;
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    _retrying = true;
    final image = widget.image;
    final cacheWidth = widget.cacheWidth;
    try {
      await retryTourImage(
        context: context,
        image: image,
        cacheWidth: cacheWidth,
        onEvicted: () {
          if (widget.image == image && widget.cacheWidth == cacheWidth) {
            setState(() => _revision++);
          }
        },
      );
    } finally {
      _retrying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      key: ValueKey(_revision),
      image: tourImageProvider(widget.image, cacheWidth: widget.cacheWidth),
      width: widget.width,
      fit: widget.fit,
      semanticLabel: widget.semanticLabel,
      loadingBuilder: tourImageLoadingBuilder,
      errorBuilder: (context, error, stackTrace) => tourImageErrorBuilder(
          context, error, stackTrace,
          onRetry: () => _retry()),
    );
  }
}

class TourImageFailure extends StatelessWidget {
  const TourImageFailure({
    Key? key,
    required this.error,
    this.onRetry,
    this.compact = false,
    this.networkStatus,
  }) : super(key: key);

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;
  final NetworkStatusMonitor? networkStatus;

  @override
  Widget build(BuildContext context) {
    if (isPossibleConnectionFailure(error)) {
      return ConnectionAwareFailure(
        onRetry: onRetry,
        compact: compact,
        networkStatus: networkStatus,
      );
    }
    final message = localization(context).errorLoadingData;
    if (compact) {
      return Center(
        child: Tooltip(
          message: message,
          child: Icon(Icons.broken_image_outlined, semanticLabel: message),
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, semanticLabel: message),
            Semantics(
              liveRegion: true,
              child: Text(message, textAlign: TextAlign.center),
            ),
            if (onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(localization(context).retryImage),
              ),
          ],
        ),
      ),
    );
  }
}
