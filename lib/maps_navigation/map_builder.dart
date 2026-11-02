import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helper/accessibility_theme.dart';
import '../helper/connection_problem_view.dart';
import '../helper/images_loader_helper.dart';
import '../helper/internet_connectivity.dart';
import '../helper/responsive_layout.dart';
import '../localization/supported_languages.dart';
import '../navigation/bottom_navigation.dart';
import '../navigation/cutom_app_bar.dart';
import '../navigation/navigation_helper.dart';

const _mapAttribution = '© OpenStreetMap';

class MapPage extends StatelessWidget {
  const MapPage({Key? key, this.tileProvider}) : super(key: key);

  final TileProvider? tileProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        localization(context).mapPage,
        const Color.fromRGBO(11, 20, 32, 1),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        unselectedColor: Color.fromRGBO(11, 20, 32, 1),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _ConnectivityAwareMap(tileProvider: tileProvider),
      ),
    );
  }
}

Widget buildWithMarkers(
  BuildContext context,
  List<Map<String, dynamic>> data,
  Widget Function(Map<String, dynamic>) buildDetailsPage,
) {
  return _PlacesView(data: data, buildDetailsPage: buildDetailsPage);
}

class _PlacesView extends StatefulWidget {
  const _PlacesView({required this.data, required this.buildDetailsPage});

  final List<Map<String, dynamic>> data;
  final Widget Function(Map<String, dynamic>) buildDetailsPage;

  @override
  State<_PlacesView> createState() => _PlacesViewState();
}

class _PlacesViewState extends State<_PlacesView> {
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    final markers = widget.data.map((item) {
      return Marker(
        point: LatLng(item['latitude'] as double, item['longitude'] as double),
        width: 48,
        height: 48,
        child: Semantics(
          button: true,
          label: item['title'] as String,
          child: GestureDetector(
            onTap: () =>
                showDetailsPage(context, widget.buildDetailsPage(item)),
            child: Tooltip(
              message: item['title'] as String,
              child: const Icon(
                Icons.location_pin,
                size: 36,
                color: Color.fromRGBO(11, 20, 32, 1),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final headerHeight =
            min(constraints.maxHeight, max(48.0, constraints.maxHeight * 0.4));
        return Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: headerHeight),
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    _ViewToggle(
                      label: localization(context).mapView,
                      selected: _showMap,
                      onPressed: () => setState(() => _showMap = true),
                    ),
                    _ViewToggle(
                      label: localization(context).listView,
                      selected: !_showMap,
                      onPressed: () => setState(() => _showMap = false),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _showMap
                  ? _ConnectivityAwareMap(markers: markers, restrictZoom: true)
                  : ListView.builder(
                      itemCount: widget.data.length,
                      itemBuilder: (context, index) {
                        final item = widget.data[index];
                        return ListTile(
                          title: Text(item['title'] as String),
                          leading: const ExcludeSemantics(
                            child: Icon(Icons.location_on_outlined),
                          ),
                          trailing: const ExcludeSemantics(
                            child: Icon(Icons.chevron_right),
                          ),
                          onTap: () => showDetailsPage(
                              context, widget.buildDetailsPage(item)),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const color = Color.fromRGBO(11, 20, 32, 1);
    return Semantics(
      selected: selected,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: selected ? Colors.white : color,
          backgroundColor: selected ? color : Colors.white,
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _ConnectivityAwareMap extends StatefulWidget {
  const _ConnectivityAwareMap({
    this.markers = const [],
    this.restrictZoom = false,
    this.tileProvider,
  });

  final List<Marker> markers;
  final bool restrictZoom;
  final TileProvider? tileProvider;

  @override
  State<_ConnectivityAwareMap> createState() => _ConnectivityAwareMapState();
}

class _ConnectivityAwareMapState extends State<_ConnectivityAwareMap> {
  final MapController _mapController = MapController();
  final NetworkStatusMonitor _networkStatus = NetworkStatusMonitor.instance;
  TileProvider? _activeTileProvider;
  final Set<ImageProvider> _failedTileImages = {};
  MapCamera? _lastCamera;
  bool _mapReady = false;
  bool _mapVisible = false;
  bool _tileConnectionFailure = false;
  bool _retryingTiles = false;
  bool _retryTilesAgain = false;
  int _tileRevision = 0;

  @override
  void initState() {
    super.initState();
    _networkStatus.addListener(_onNetworkStatusChanged);
  }

  @override
  void didUpdateWidget(covariant _ConnectivityAwareMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tileProvider != widget.tileProvider) {
      final previous = oldWidget.tileProvider;
      _activeTileProvider = null;
      _failedTileImages.clear();
      _tileRevision++;
      _tileConnectionFailure = false;
      if (previous != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
      }
    }
  }

  void _retry() {
    unawaited(_networkStatus.refresh());
  }

  void _onNetworkStatusChanged() {
    if (!mounted) return;
    if (_networkStatus.status == NetworkStatus.connected &&
        _failedTileImages.isNotEmpty) {
      unawaited(_retryTiles());
      return;
    }
    setState(() {
      if (_networkStatus.status != NetworkStatus.connected) {
        _rememberCamera();
        _tileConnectionFailure = false;
        if (_activeTileProvider != null) _tileRevision++;
      }
    });
  }

  void _onTileError(int revision, TileImage tile, Object error) {
    if (revision != _tileRevision ||
        (!isPossibleConnectionFailure(error) &&
            error is! http.ClientException)) {
      return;
    }
    _failedTileImages.add(tile.imageProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          revision == _tileRevision &&
          _networkStatus.status == NetworkStatus.connected &&
          !_tileConnectionFailure) {
        setState(() => _tileConnectionFailure = true);
      }
    });
  }

  Future<void> _retryTiles() async {
    if (_retryingTiles) {
      _retryTilesAgain = true;
      return;
    }
    setState(() => _retryingTiles = true);
    final revision = _tileRevision;
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || revision != _tileRevision) return;
      await retryImageProviders(
        context: context,
        providers: () => List<ImageProvider>.of(_failedTileImages),
        onEvicted: () {
          if (revision != _tileRevision) return;
          setState(() {
            _tileConnectionFailure = false;
            _activeTileProvider = null;
            _failedTileImages.clear();
            _tileRevision++;
            _retryingTiles = false;
          });
        },
      );
    } finally {
      final retryAgain = mounted &&
          _retryTilesAgain &&
          _networkStatus.status == NetworkStatus.connected &&
          _failedTileImages.isNotEmpty;
      _retryTilesAgain = false;
      if (mounted && _retryingTiles) {
        setState(() => _retryingTiles = false);
      } else {
        _retryingTiles = false;
      }
      if (retryAgain) unawaited(_retryTiles());
    }
  }

  void _rememberCamera() {
    if (_mapReady) _lastCamera = _mapController.camera;
    _mapReady = false;
  }

  bool _needsFullConnectionView(
      BuildContext context, BoxConstraints constraints) {
    if (!_tileConnectionFailure ||
        !constraints.hasBoundedWidth ||
        !constraints.hasBoundedHeight) {
      return false;
    }
    const controlCount = 7;
    const controlExtent = 48.0;
    final columns = max(1, (constraints.maxWidth / controlExtent).floor());
    final rows = (controlCount + columns - 1) ~/ columns;
    final mapHeight =
        max(0.0, constraints.maxHeight - rows * controlExtent) * 2 / 3;
    final creditWidth = max(1.0, min(400.0, constraints.maxWidth) - 8);
    final creditStyle =
        Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);
    final textHeight =
        measureTextHeight(context, _mapAttribution, creditStyle, creditWidth);
    final creditHeight = max(48.0, textHeight + 8);
    return mapHeight < creditHeight;
  }

  @override
  void dispose() {
    _networkStatus.removeListener(_onNetworkStatusChanged);
    _mapController.dispose();
    widget.tileProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_networkStatus.status == NetworkStatus.unknown) {
      _mapVisible = false;
      return Center(
        child: CircularProgressIndicator(
          semanticsLabel: localization(context).loading,
        ),
      );
    }
    if (_networkStatus.status == NetworkStatus.error) {
      _mapVisible = false;
      _activeTileProvider = null;
      return _connectionError(context);
    }
    if (_networkStatus.status == NetworkStatus.disconnected) {
      _mapVisible = false;
      _rememberCamera();
      _activeTileProvider = null;
      return ConnectionProblemView(disconnected: true, onRetry: _retry);
    }
    if (_retryingTiles) {
      _mapVisible = false;
      _rememberCamera();
      _activeTileProvider = null;
      return Center(
        child: CircularProgressIndicator(
          semanticsLabel: localization(context).loading,
        ),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      if (_needsFullConnectionView(context, constraints)) {
        _mapVisible = false;
        _rememberCamera();
        _activeTileProvider = null;
        return ConnectionProblemView(
          disconnected: false,
          onRetry: () => _retryTiles(),
        );
      }
      _mapVisible = true;
      final tileProvider = _activeTileProvider ??= widget.tileProvider == null
          ? NetworkTileProvider()
          : _BorrowedTileProvider(widget.tileProvider!);
      final tileRevision = _tileRevision;
      return Column(
        children: [
          Expanded(
            child: Column(
              children: [
                if (_tileConnectionFailure)
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: ConnectionProblemView(
                        disconnected: false,
                        compact: true,
                        onRetry: () => _retryTiles(),
                      ),
                    ),
                  ),
                Expanded(
                  key: const ValueKey('map'),
                  flex: 2,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          _lastCamera?.center ?? const LatLng(44.267, 19.886),
                      initialZoom: _lastCamera?.zoom ?? 13,
                      initialRotation: _lastCamera?.rotation ?? 0,
                      minZoom: widget.restrictZoom ? 10 : null,
                      maxZoom: widget.restrictZoom ? 18 : null,
                      onMapReady: () {
                        if (mounted && _mapVisible) {
                          setState(() => _mapReady = true);
                        }
                      },
                    ),
                    children: [
                      Stack(
                        children: [
                          Semantics(
                            label: localization(context).map,
                            child: TileLayer(
                              key: ValueKey(_tileRevision),
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.andjelkadzida.vodic_kroz_valjevo',
                              tileProvider: tileProvider,
                              evictErrorTileStrategy:
                                  EvictErrorTileStrategy.dispose,
                              errorTileCallback: (tile, error, stackTrace) =>
                                  _onTileError(tileRevision, tile, error),
                            ),
                          ),
                          if (widget.markers.isNotEmpty)
                            MarkerLayer(markers: widget.markers),
                          const Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: AlignmentDirectional.bottomEnd,
                              child: _MapCredits(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _MapControls(controller: _mapController, enabled: _mapReady),
        ],
      );
    });
  }

  Widget _connectionError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localization(context).errorLoadingData),
          IconButton(
            onPressed: _retry,
            tooltip:
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            icon: Icon(
              Icons.refresh,
              semanticLabel: MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowedTileProvider extends TileProvider {
  _BorrowedTileProvider(this.provider) : super(headers: provider.headers);

  final TileProvider provider;

  @override
  bool get supportsCancelLoading => provider.supportsCancelLoading;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      provider.getImage(coordinates, options);

  @override
  ImageProvider getImageWithCancelLoadingSupport(
    TileCoordinates coordinates,
    TileLayer options,
    Future<void> cancelLoading,
  ) =>
      provider.getImageWithCancelLoadingSupport(
        coordinates,
        options,
        cancelLoading,
      );
}

class _MapControls extends StatelessWidget {
  const _MapControls({required this.controller, required this.enabled});

  final MapController controller;
  final bool enabled;

  void _move(Offset offset) {
    final camera = controller.camera;
    controller.move(camera.center, camera.zoom, offset: offset);
  }

  void _zoom(double delta) {
    final camera = controller.camera;
    final zoom = (camera.zoom + delta)
        .clamp(camera.minZoom ?? 0.0, camera.maxZoom ?? 18.0)
        .toDouble();
    controller.move(camera.center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final messages = localization(context);
    return Material(
      color: Colors.white,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          IconButton(
            tooltip: messages.moveMapUp,
            onPressed: enabled ? () => _move(const Offset(0, -96)) : null,
            icon: Icon(Icons.arrow_upward, semanticLabel: messages.moveMapUp),
          ),
          IconButton(
            tooltip: messages.moveMapDown,
            onPressed: enabled ? () => _move(const Offset(0, 96)) : null,
            icon:
                Icon(Icons.arrow_downward, semanticLabel: messages.moveMapDown),
          ),
          IconButton(
            tooltip: messages.moveMapLeft,
            onPressed: enabled ? () => _move(const Offset(-96, 0)) : null,
            icon: Icon(Icons.arrow_back, semanticLabel: messages.moveMapLeft),
          ),
          IconButton(
            tooltip: messages.moveMapRight,
            onPressed: enabled ? () => _move(const Offset(96, 0)) : null,
            icon:
                Icon(Icons.arrow_forward, semanticLabel: messages.moveMapRight),
          ),
          IconButton(
            tooltip: messages.zoomOut,
            onPressed: enabled ? () => _zoom(-1) : null,
            icon: Icon(Icons.zoom_out, semanticLabel: messages.zoomOut),
          ),
          IconButton(
            tooltip: messages.zoomIn,
            onPressed: enabled ? () => _zoom(1) : null,
            icon: Icon(Icons.zoom_in, semanticLabel: messages.zoomIn),
          ),
          IconButton(
            tooltip: messages.resetMap,
            onPressed: enabled
                ? () => controller.move(const LatLng(44.267, 19.886), 13)
                : null,
            icon: Icon(Icons.center_focus_strong,
                semanticLabel: messages.resetMap),
          ),
        ],
      ),
    );
  }
}

class _MapCredits extends StatelessWidget {
  const _MapCredits();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max(0, min(400, width))),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () =>
              launchUrlString('https://www.openstreetmap.org/copyright'),
          child: Semantics(
            link: true,
            label: '${localization(context).mapCredits}: $_mapAttribution',
            child: ExcludeSemantics(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    _mapAttribution,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accessibleLinkColor,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
