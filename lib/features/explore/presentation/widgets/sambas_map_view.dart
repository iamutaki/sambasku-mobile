import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/sambas_map_config.dart';
import 'explore_map_poster.dart';

/// MapLibre view fokus Sambas — hero (gesture off) atau fullscreen (gesture on).
///
/// Style mengikuti tema (Liberty / Dark). Gagal load → [ExploreMapPoster].
class SambasMapView extends StatefulWidget {
  const SambasMapView({
    super.key,
    required this.initialCameraPosition,
    this.interactive = true,
    this.onMapClick,
    this.onMapCreated,
    this.onFallbackTap,
    this.analyticsEntry = 'category',
  });

  final CameraPosition initialCameraPosition;
  final bool interactive;
  final OnMapClickCallback? onMapClick;
  final MapCreatedCallback? onMapCreated;

  /// Dipakai poster fallback (biasanya buka Peta & Akses).
  final VoidCallback? onFallbackTap;

  /// Param `entry` untuk `map_open` / `map_fallback_shown`.
  final String analyticsEntry;

  @override
  State<SambasMapView> createState() => _SambasMapViewState();
}

class _SambasMapViewState extends State<SambasMapView> {
  static const _loadTimeout = Duration(seconds: 12);

  bool _usePoster = false;
  Timer? _timeout;
  bool _styleReady = false;
  Brightness? _lastBrightness;

  @override
  void initState() {
    super.initState();
    _armTimeout();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != null &&
        _lastBrightness != brightness &&
        !_usePoster) {
      _styleReady = false;
      _armTimeout();
    }
    _lastBrightness = brightness;
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  void _armTimeout() {
    _timeout?.cancel();
    _timeout = Timer(_loadTimeout, () {
      if (!mounted || _styleReady || _usePoster) return;
      _showPoster('offline');
    });
  }

  void _showPoster(String reason) {
    _timeout?.cancel();
    if (_usePoster) return;
    setState(() {
      _usePoster = true;
    });
    unawaited(
      AnalyticsService.instance.logMapFallback(reason: reason),
    );
  }

  void _onStyleLoaded() {
    _styleReady = true;
    _timeout?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_usePoster) {
      return ExploreMapPoster(
        onTap: widget.onFallbackTap,
        compact: !widget.interactive,
      );
    }

    final brightness = Theme.of(context).brightness;
    final styleUrl = SambasMapConfig.styleUrlFor(brightness);

    return MapLibreMap(
      key: ValueKey('sambas-map-$styleUrl'),
      styleString: styleUrl,
      initialCameraPosition: widget.initialCameraPosition,
      onMapCreated: (controller) {
        widget.onMapCreated?.call(controller);
      },
      onStyleLoadedCallback: _onStyleLoaded,
      onMapClick: widget.onMapClick,
      compassEnabled: widget.interactive,
      rotateGesturesEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
      doubleClickZoomEnabled: widget.interactive,
      dragEnabled: widget.interactive,
      myLocationEnabled: false,
      logoEnabled: false,
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      attributionButtonMargins: const math.Point(8, 8),
      annotationOrder: const [],
      foregroundLoadColor: Theme.of(context).colorScheme.surface,
    );
  }
}
