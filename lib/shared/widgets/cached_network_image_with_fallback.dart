import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'image_placeholder_256.dart';

bool isSvgNetworkUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return uri.path.toLowerCase().endsWith('.svg');
}

class CachedNetworkImageWithFallback extends StatefulWidget {
  const CachedNetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.fallback = const ImagePlaceholder256(),
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String imageUrl;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<CachedNetworkImageWithFallback> createState() =>
      _CachedNetworkImageWithFallbackState();
}

class _CachedNetworkImageWithFallbackState
    extends State<CachedNetworkImageWithFallback> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) {
      return widget.fallback;
    }

    if (isSvgNetworkUrl(widget.imageUrl)) {
      return SvgPicture.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholderBuilder: (_) => const Skeletonizer(child: Bone()),
        errorBuilder: (_, _, _) => widget.fallback,
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      alignment: widget.alignment,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => const Skeletonizer(child: Bone()),
      errorWidget: (_, _, _) => widget.fallback,
    );
  }
}
