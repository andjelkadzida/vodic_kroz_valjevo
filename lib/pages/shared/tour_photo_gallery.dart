import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../helper/images_loader_helper.dart';
import '../../localization/supported_languages.dart';

class TourPhotoGallery extends StatefulWidget {
  const TourPhotoGallery({
    Key? key,
    required this.images,
    required this.semanticLabel,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  final List<String> images;
  final String semanticLabel;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<TourPhotoGallery> createState() => _TourPhotoGalleryState();
}

class _TourPhotoGalleryState extends State<TourPhotoGallery> {
  final PageController _pages = PageController();
  late List<PhotoViewController> _photos;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  Size? _imageSize;
  int _current = 0;
  int _revision = 0;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _createControllers();
    _observeCurrentImage();
  }

  void _createControllers() {
    _photos = List.generate(widget.images.length, (_) => PhotoViewController());
  }

  void _observeCurrentImage() {
    _stopObservingImage();
    _imageSize = null;
    final index = _current;
    final stream = tourImageProvider(widget.images[index])
        .resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (info, synchronousCall) {
        final size =
            Size(info.image.width.toDouble(), info.image.height.toDouble());
        info.dispose();
        if (!mounted ||
            index != _current ||
            !identical(_imageStream, stream) ||
            _imageSize == size) {
          return;
        }
        if (synchronousCall) {
          _imageSize = size;
        } else {
          setState(() => _imageSize = size);
        }
      },
      onError: (Object error, StackTrace? stackTrace) {
        // The gallery's error builder presents the failure and retry action.
        if (mounted &&
            index == _current &&
            identical(_imageStream, stream) &&
            _imageSize != null) {
          setState(() => _imageSize = null);
        }
      },
    );
    _imageStream = stream;
    _imageListener = listener;
    stream.addListener(listener);
  }

  void _stopObservingImage() {
    final stream = _imageStream;
    final listener = _imageListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _imageStream = null;
    _imageListener = null;
  }

  @override
  void didUpdateWidget(covariant TourPhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.images, widget.images)) {
      final oldControllers = _photos;
      _createControllers();
      _current = 0;
      _revision++;
      _observeCurrentImage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final controller in oldControllers) {
          controller.dispose();
        }
        if (mounted && _pages.hasClients) _pages.jumpToPage(0);
      });
    }
  }

  @override
  void dispose() {
    _stopObservingImage();
    _pages.dispose();
    for (final controller in _photos) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changePage(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _zoom(double factor, double base) {
    final controller = _photos[_current];
    final scale = controller.scale;
    if (scale == null) return;
    controller.scale = (scale * factor).clamp(base, base * 5);
  }

  void _moveImage(Offset offset) {
    final controller = _photos[_current];
    controller.position = controller.position + offset;
  }

  Future<void> _retryImage(int index) async {
    if (_retrying) return;
    _retrying = true;
    final image = widget.images[index];
    try {
      await retryTourImage(
        context: context,
        image: image,
        onEvicted: () {
          if (index >= widget.images.length || widget.images[index] != image) {
            return;
          }
          setState(() {
            _revision++;
            if (index == _current) _observeCurrentImage();
          });
        },
      );
    } finally {
      _retrying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final controller = _photos[_current];
      final imageSize = _imageSize;
      final base = imageSize == null || !constraints.hasBoundedWidth
          ? null
          : math.min(constraints.maxWidth / imageSize.width,
              widget.height / imageSize.height);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: widget.semanticLabel,
            child: SizedBox(
              height: widget.height,
              child: ClipRRect(
                borderRadius: widget.borderRadius,
                child: PhotoViewGallery.builder(
                  key: ValueKey(_revision),
                  pageController: _pages,
                  itemCount: widget.images.length,
                  onPageChanged: (page) => setState(() {
                    _current = page;
                    _observeCurrentImage();
                  }),
                  builder: (context, index) => PhotoViewGalleryPageOptions(
                    imageProvider: tourImageProvider(widget.images[index]),
                    controller: _photos[index],
                    errorBuilder: (context, error, stackTrace) =>
                        TourImageFailure(
                      error: error,
                      onRetry: () => _retryImage(index),
                    ),
                    maxScale: PhotoViewComputedScale.contained * 5,
                    minScale: PhotoViewComputedScale.contained,
                    initialScale: PhotoViewComputedScale.contained,
                    basePosition: Alignment.center,
                    filterQuality: FilterQuality.high,
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.images[index]),
                  ),
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration:
                      BoxDecoration(color: Theme.of(context).canvasColor),
                  loadingBuilder: (context, _) => Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: localization(context).loading,
                    ),
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<PhotoViewControllerValue>(
            stream: controller.outputStateStream,
            initialData: controller.value,
            builder: (context, snapshot) {
              final scale = snapshot.data?.scale;
              return Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    tooltip: localization(context).previousPhoto,
                    onPressed:
                        _current > 0 ? () => _changePage(_current - 1) : null,
                    icon: Icon(Icons.chevron_left,
                        semanticLabel: localization(context).previousPhoto),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Text(localization(context)
                        .positionInList(_current + 1, widget.images.length)),
                  ),
                  IconButton(
                    tooltip: localization(context).nextPhoto,
                    onPressed: _current + 1 < widget.images.length
                        ? () => _changePage(_current + 1)
                        : null,
                    icon: Icon(Icons.chevron_right,
                        semanticLabel: localization(context).nextPhoto),
                  ),
                  IconButton(
                    tooltip: localization(context).zoomOut,
                    onPressed: base != null && scale != null && scale > base
                        ? () => _zoom(1 / 1.5, base)
                        : null,
                    icon: Icon(Icons.zoom_out,
                        semanticLabel: localization(context).zoomOut),
                  ),
                  IconButton(
                    tooltip: localization(context).zoomIn,
                    onPressed: base != null && scale != null && scale < base * 5
                        ? () => _zoom(1.5, base)
                        : null,
                    icon: Icon(Icons.zoom_in,
                        semanticLabel: localization(context).zoomIn),
                  ),
                  IconButton(
                    tooltip: localization(context).resetZoom,
                    onPressed: base == null
                        ? null
                        : () => controller.updateMultiple(
                              position: Offset.zero,
                              scale: base,
                            ),
                    icon: Icon(Icons.fit_screen,
                        semanticLabel: localization(context).resetZoom),
                  ),
                  if (base != null && scale != null && scale > base) ...[
                    IconButton(
                      tooltip: localization(context).movePhotoUp,
                      onPressed: () => _moveImage(const Offset(0, -48)),
                      icon: Icon(Icons.arrow_upward,
                          semanticLabel: localization(context).movePhotoUp),
                    ),
                    IconButton(
                      tooltip: localization(context).movePhotoDown,
                      onPressed: () => _moveImage(const Offset(0, 48)),
                      icon: Icon(Icons.arrow_downward,
                          semanticLabel: localization(context).movePhotoDown),
                    ),
                    IconButton(
                      tooltip: localization(context).movePhotoLeft,
                      onPressed: () => _moveImage(const Offset(-48, 0)),
                      icon: Icon(Icons.arrow_back,
                          semanticLabel: localization(context).movePhotoLeft),
                    ),
                    IconButton(
                      tooltip: localization(context).movePhotoRight,
                      onPressed: () => _moveImage(const Offset(48, 0)),
                      icon: Icon(Icons.arrow_forward,
                          semanticLabel: localization(context).movePhotoRight),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      );
    });
  }
}
