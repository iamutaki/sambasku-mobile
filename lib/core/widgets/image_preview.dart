import 'package:flutter/material.dart';

import '../../shared/widgets/cached_network_image_with_fallback.dart';
import '../utils/display_image_url.dart';

/// Buka preview fullscreen dengan pinch-zoom.
///
/// [urls] boleh satu atau banyak; [initialIndex] memilih halaman awal.
/// Dipakai lintas fitur (detail kata, kontribusi, dll.).
Future<void> showImagePreview(
  BuildContext context, {
  required List<String> urls,
  int initialIndex = 0,
}) {
  final cleaned = urls.where((u) => u.trim().isNotEmpty).toList(growable: false);
  if (cleaned.isEmpty) return Future.value();

  final index = initialIndex.clamp(0, cleaned.length - 1);
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, _) => FadeTransition(
        opacity: animation,
        child: ImagePreview(
          urls: cleaned,
          initialIndex: index,
        ),
      ),
    ),
  );
}

/// Preview gambar fullscreen + pinch/pan zoom (`InteractiveViewer`).
/// Multi-URL → swipe horizontal antar gambar.
class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final multi = widget.urls.length > 1;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => _ZoomableNetworkImage(url: widget.urls[i]),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Tutup',
                onPressed: _close,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            if (multi)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Text(
                  '${_index + 1} / ${widget.urls.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoomableNetworkImage extends StatelessWidget {
  const _ZoomableNetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      child: SizedBox.expand(
        child: CachedNetworkImageWithFallback(
          imageUrl: displayImageUrl(url, width: 1200) ?? url,
          fallbackUrl: url,
          fit: BoxFit.contain,
          fallback: const Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 48,
          ),
        ),
      ),
    );
  }
}
