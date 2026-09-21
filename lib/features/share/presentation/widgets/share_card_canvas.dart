import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/share_models.dart';
import 'share_video_layer.dart';

/// Template kartu share (preview + PNG overlay).
class ShareCardCanvas extends StatelessWidget {
  const ShareCardCanvas({
    super.key,
    required this.data,
    required this.template,
    required this.ratio,
    required this.settings,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
    this.layoutEditMode = false,
    this.selectedElement,
    this.onSelectElement,
    this.onPanElement,
  });

  final ShareCardData data;
  final ShareTemplateId template;
  final ShareRatioId ratio;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final bool layoutEditMode;
  final ShareTextElementId? selectedElement;
  final ValueChanged<ShareTextElementId>? onSelectElement;
  final void Function(ShareTextElementId id, Offset canvasDelta)? onPanElement;

  @override
  Widget build(BuildContext context) {
    final layout = _LayoutCallbacks(
      editMode: layoutEditMode,
      selected: selectedElement,
      onSelect: onSelectElement,
      onPan: onPanElement,
    );
    return SizedBox(
      width: ratio.width,
      height: ratio.height,
      child: switch (template) {
        ShareTemplateId.unsplash => _UnsplashCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kamusEditorial => _KamusEditorialCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.posterHuruf => _PosterHurufCard(
          data: data,
          settings: settings,
          layout: layout,
        ),
        ShareTemplateId.polaroid => _PolaroidCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.sisi => _SisiCard(
          data: data,
          settings: settings,
          ratio: ratio,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kaca => _KacaCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kutipan => _KutipanCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
        ShareTemplateId.kartu => _KartuCard(
          data: data,
          settings: settings,
          imageProvider: imageProvider,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
          layout: layout,
        ),
      },
    );
  }
}

class _LayoutCallbacks {
  const _LayoutCallbacks({
    required this.editMode,
    required this.selected,
    required this.onSelect,
    required this.onPan,
  });

  final bool editMode;
  final ShareTextElementId? selected;
  final ValueChanged<ShareTextElementId>? onSelect;
  final void Function(ShareTextElementId id, Offset canvasDelta)? onPan;
}

TextStyle _lemmaStyle({
  required ShareFontPair pair,
  required double size,
  required Color color,
}) {
  final base = switch (pair) {
    ShareFontPair.classic => GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.5,
    ),
    ShareFontPair.editorial => GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.3,
    ),
    ShareFontPair.modern => GoogleFonts.outfit(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.4,
    ),
  };
  return base.copyWith(color: color);
}

TextStyle _bodyStyle({
  required ShareFontPair pair,
  required double size,
  required Color color,
}) {
  final base = switch (pair) {
    ShareFontPair.classic => GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
    ShareFontPair.editorial => GoogleFonts.sourceSans3(
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
    ShareFontPair.modern => GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
  };
  return base.copyWith(color: color);
}

Widget _photoOrGradient({
  required ImageProvider? imageProvider,
  required List<Color> gradient,
  String? videoUrl,
  bool videoIsFile = false,
  bool transparentBackdrop = false,
}) {
  if (transparentBackdrop) {
    return const ColoredBox(color: Color(0x00000000));
  }
  if (videoUrl != null && videoUrl.isNotEmpty) {
    return ShareVideoLayer(
      url: videoUrl,
      isFile: videoIsFile,
      fallback: imageProvider,
      gradient: gradient,
    );
  }
  if (imageProvider == null) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
    );
  }
  return Image(
    image: imageProvider,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    errorBuilder: (_, _, _) => DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
    ),
  );
}

Widget _classPill(
  String? label,
  Color fg, {
  required ShareFontPair pair,
}) {
  if (label == null || label.isEmpty) return const SizedBox.shrink();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: fg.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: fg.withValues(alpha: 0.35)),
    ),
    child: Text(label, style: _bodyStyle(pair: pair, size: 22, color: fg)),
  );
}

Widget _watermark({required ShareCardData data, required ShareFontPair pair}) {
  final photo = data.photographer;
  final radius = BorderRadius.circular(
    photo != null && photo.isNotEmpty ? 20 : 999,
  );

  return ClipRRect(
    borderRadius: radius,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: radius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SambasKu',
              style: _bodyStyle(pair: pair, size: 26, color: Colors.white)
                  .copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    shadows: const [
                      Shadow(
                        color: Color(0x66000000),
                        blurRadius: 8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
            ),
            if (photo != null && photo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Foto: $photo / Unsplash',
                style: _bodyStyle(
                  pair: pair,
                  size: 15,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Bungkus elemen agar bisa di-drag saat mode atur posisi.
///
/// Transform harus membungkus GestureDetector (bukan sebaliknya): hit-test
/// mengikuti posisi visual. Kalau GestureDetector di luar, setelah digeser
/// target sentuhan masih di slot layout asli → elemen “macet”.
Widget _laidOut({
  required ShareTextElementId id,
  required ShareEditorSettings settings,
  required _LayoutCallbacks layout,
  required Widget child,
}) {
  final l = settings.layoutFor(id);
  final selected = layout.selected == id;
  Widget inner = child;
  if (layout.editMode) {
    inner = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? const Color(0xFF38BDF8) : Colors.white38,
          width: selected ? 3 : 1.5,
        ),
      ),
      child: child,
    );
  }

  if (!layout.editMode) {
    return Transform.translate(
      offset: l.offset,
      child: Transform.rotate(
        angle: l.rotationDeg * math.pi / 180,
        child: inner,
      ),
    );
  }

  return Transform.translate(
    offset: l.offset,
    child: Transform.rotate(
      angle: l.rotationDeg * math.pi / 180,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => layout.onSelect?.call(id),
        onPanStart: (_) => layout.onSelect?.call(id),
        onPanUpdate: (d) => layout.onPan?.call(id, d.delta),
        child: inner,
      ),
    ),
  );
}

class _UnsplashCard extends StatelessWidget {
  const _UnsplashCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 120 * settings.lemmaFontScale;
    final bodySize = 40 * settings.bodyFontScale;
    final overlay = settings.overlayStrength.clamp(0.0, 1.0);
    final gradient = settings.gradientId.colors;

    return Stack(
      fit: StackFit.expand,
      children: [
        _photoOrGradient(
          imageProvider: imageProvider,
          gradient: gradient,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(0, 0, 0, 0.2 * overlay),
                Colors.transparent,
                Color.fromRGBO(0, 0, 0, 0.85 * overlay + 0.15),
              ],
              stops: const [0, 0.35, 1],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 160, 72, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (settings.showWordClass)
                _laidOut(
                  id: ShareTextElementId.wordClass,
                  settings: settings,
                  layout: layout,
                  child: _classPill(
                    data.wordClassName,
                    lemmaColor,
                    pair: pair,
                  ),
                ),
              const Spacer(),
              _laidOut(
                id: ShareTextElementId.lemma,
                settings: settings,
                layout: layout,
                child: Text(
                  data.lemma,
                  style: _lemmaStyle(
                    pair: pair,
                    size: lemmaSize,
                    color: lemmaColor,
                  ),
                ),
              ),
              if (settings.showPadanan &&
                  data.padanan != null &&
                  data.padanan!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _laidOut(
                  id: ShareTextElementId.padanan,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    '→ ${data.padanan}',
                    style: _bodyStyle(
                      pair: pair,
                      size: 44 * settings.bodyFontScale,
                      color: lemmaColor,
                    ),
                  ),
                ),
              ],
              if (settings.showDefinition &&
                  data.definition != null &&
                  data.definition!.isNotEmpty) ...[
                const SizedBox(height: 28),
                _laidOut(
                  id: ShareTextElementId.definition,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    data.definition!,
                    maxLines: 6,
                    softWrap: true,
                    style: _bodyStyle(
                      pair: pair,
                      size: bodySize,
                      color: bodyColor,
                    ),
                  ),
                ),
              ],
              if (settings.showExample &&
                  data.exampleSentence != null &&
                  data.exampleSentence!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _laidOut(
                  id: ShareTextElementId.example,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    '"${data.exampleSentence}"',
                    maxLines: 4,
                    softWrap: true,
                    style: _bodyStyle(
                      pair: pair,
                      size: 32 * settings.bodyFontScale,
                      color: bodyColor,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KamusEditorialCard extends StatelessWidget {
  const _KamusEditorialCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  static const _paper = Color(0xFFF3EDE2);
  static const _paperDark = Color(0xFF1C1917);

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final bg = dark ? _paperDark : _paper;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 110 * settings.lemmaFontScale;
    final mutedHeader = bodyColor.withValues(alpha: 0.7);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: bg,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(72, 140, 72, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KAMUS SAMBAS',
                            style: _bodyStyle(
                              pair: pair,
                              size: 20,
                              color: mutedHeader,
                            ).copyWith(
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _laidOut(
                            id: ShareTextElementId.lemma,
                            settings: settings,
                            layout: layout,
                            child: Text(
                              data.lemma,
                              style: _lemmaStyle(
                                pair: pair,
                                size: lemmaSize,
                                color: lemmaColor,
                              ),
                            ),
                          ),
                          if (settings.showWordClass &&
                              data.wordClassName != null &&
                              data.wordClassName!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _laidOut(
                              id: ShareTextElementId.wordClass,
                              settings: settings,
                              layout: layout,
                              child: Text(
                                data.wordClassName!,
                                style: _bodyStyle(
                                  pair: pair,
                                  size: 30 * settings.bodyFontScale,
                                  color: bodyColor,
                                ).copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (imageProvider != null ||
                        (videoUrl != null && videoUrl!.isNotEmpty) ||
                        transparentBackdrop)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: _photoOrGradient(
                            imageProvider: imageProvider,
                            gradient: const [Color(0x22000000), Color(0x22000000)],
                            videoUrl: videoUrl,
                            videoIsFile: videoIsFile,
                            transparentBackdrop: transparentBackdrop,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 36),
                Container(height: 2, color: bodyColor.withValues(alpha: 0.2)),
                const SizedBox(height: 36),
                if (settings.showDefinition &&
                    data.definition != null &&
                    data.definition!.isNotEmpty)
                  _laidOut(
                    id: ShareTextElementId.definition,
                    settings: settings,
                    layout: layout,
                    child: Text(
                      data.definition!,
                      maxLines: 6,
                      softWrap: true,
                      style: _bodyStyle(
                        pair: pair,
                        size: 42 * settings.bodyFontScale,
                        color: bodyColor,
                      ),
                    ),
                  ),
                if (settings.showPadanan &&
                    data.padanan != null &&
                    data.padanan!.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _laidOut(
                    id: ShareTextElementId.padanan,
                    settings: settings,
                    layout: layout,
                    child: Text(
                      'Padanan: ${data.padanan}',
                      style: _bodyStyle(
                        pair: pair,
                        size: 36 * settings.bodyFontScale,
                        color: lemmaColor,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                if (settings.showExample &&
                    data.exampleSentence != null &&
                    data.exampleSentence!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _laidOut(
                    id: ShareTextElementId.example,
                    settings: settings,
                    layout: layout,
                    child: Text(
                      '"${data.exampleSentence}"',
                      maxLines: 4,
                      softWrap: true,
                      style: _bodyStyle(
                        pair: pair,
                        size: 32 * settings.bodyFontScale,
                        color: bodyColor,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _PosterHurufCard extends StatelessWidget {
  const _PosterHurufCard({
    required this.data,
    required this.settings,
    required this.layout,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 180 * settings.lemmaFontScale;
    final gradient = settings.gradientId.colors;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(64, 160, 64, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (settings.showWordClass)
                _laidOut(
                  id: ShareTextElementId.wordClass,
                  settings: settings,
                  layout: layout,
                  child: _classPill(
                    data.wordClassName,
                    lemmaColor,
                    pair: pair,
                  ),
                ),
              const Spacer(flex: 2),
              _laidOut(
                id: ShareTextElementId.lemma,
                settings: settings,
                layout: layout,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.lemma,
                    style: _lemmaStyle(
                      pair: pair,
                      size: lemmaSize,
                      color: lemmaColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (settings.showPadanan &&
                  data.padanan != null &&
                  data.padanan!.isNotEmpty)
                _laidOut(
                  id: ShareTextElementId.padanan,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    data.padanan!,
                    style: _bodyStyle(
                      pair: pair,
                      size: 48 * settings.bodyFontScale,
                      color: lemmaColor,
                    ),
                  ),
                ),
              if (settings.showDefinition &&
                  data.definition != null &&
                  data.definition!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _laidOut(
                  id: ShareTextElementId.definition,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    data.definition!,
                    maxLines: 6,
                    softWrap: true,
                    style: _bodyStyle(
                      pair: pair,
                      size: 34 * settings.bodyFontScale,
                      color: bodyColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _PolaroidCard extends StatelessWidget {
  const _PolaroidCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final pageBg = dark ? const Color(0xFF292524) : const Color(0xFFE7E5E4);
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final lemmaSize = 80 * settings.lemmaFontScale;
    final gradient = settings.gradientId.colors;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: pageBg,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(80, 140, 80, 120),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(36, 36, 36, 28),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1C1917) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRect(
                            child: _photoOrGradient(
                              imageProvider: imageProvider,
                              gradient: gradient,
                              videoUrl: videoUrl,
                              videoIsFile: videoIsFile,
                              transparentBackdrop: transparentBackdrop,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        _laidOut(
                          id: ShareTextElementId.lemma,
                          settings: settings,
                          layout: layout,
                          child: Text(
                            data.lemma,
                            textAlign: TextAlign.center,
                            style: _lemmaStyle(
                              pair: pair,
                              size: lemmaSize,
                              color: lemmaColor,
                            ),
                          ),
                        ),
                        if (settings.showPadanan &&
                            data.padanan != null &&
                            data.padanan!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _laidOut(
                            id: ShareTextElementId.padanan,
                            settings: settings,
                            layout: layout,
                            child: Text(
                              data.padanan!,
                              textAlign: TextAlign.center,
                              style: _bodyStyle(
                                pair: pair,
                                size: 34 * settings.bodyFontScale,
                                color: bodyColor,
                              ),
                            ),
                          ),
                        ],
                        if (settings.showWordClass &&
                            data.wordClassName != null &&
                            data.wordClassName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _laidOut(
                            id: ShareTextElementId.wordClass,
                            settings: settings,
                            layout: layout,
                            child: Text(
                              data.wordClassName!,
                              textAlign: TextAlign.center,
                              style: _bodyStyle(
                                pair: pair,
                                size: 26 * settings.bodyFontScale,
                                color: bodyColor.withValues(alpha: 0.85),
                              ).copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                if (settings.showDefinition &&
                    data.definition != null &&
                    data.definition!.isNotEmpty)
                  _laidOut(
                    id: ShareTextElementId.definition,
                    settings: settings,
                    layout: layout,
                    child: Text(
                      data.definition!,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      softWrap: true,
                      style: _bodyStyle(
                        pair: pair,
                        size: 32 * settings.bodyFontScale,
                        color: bodyColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _SisiCard extends StatelessWidget {
  const _SisiCard({
    required this.data,
    required this.settings,
    required this.ratio,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ShareRatioId ratio;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final panel = dark ? const Color(0xFF1C1917) : const Color(0xFFF5F0E8);
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final gradient = settings.gradientId.colors;
    final media = ClipRect(
      child: _photoOrGradient(
        imageProvider: imageProvider,
        gradient: gradient,
        videoUrl: videoUrl,
        videoIsFile: videoIsFile,
        transparentBackdrop: transparentBackdrop,
      ),
    );
    final text = ColoredBox(
      color: panel,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 64, 56, 120),
        child: _stackedCopy(
          data: data,
          settings: settings,
          layout: layout,
          pair: pair,
          lemmaColor: lemmaColor,
          bodyColor: bodyColor,
          lemmaSize: 88 * settings.lemmaFontScale,
          align: CrossAxisAlignment.start,
        ),
      ),
    );
    final split = ratio == ShareRatioId.post
        ? Row(
            children: [
              Expanded(flex: 5, child: media),
              Expanded(flex: 5, child: text),
            ],
          )
        : Column(
            children: [
              Expanded(flex: 11, child: media),
              Expanded(flex: 9, child: text),
            ],
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        split,
        if (settings.showWatermark)
          Positioned(
            right: 40,
            bottom: 40,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KacaCard extends StatelessWidget {
  const _KacaCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final overlay = settings.overlayStrength.clamp(0.0, 1.0);
    final gradient = settings.gradientId.colors;

    return Stack(
      fit: StackFit.expand,
      children: [
        _photoOrGradient(
          imageProvider: imageProvider,
          gradient: gradient,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color.fromRGBO(0, 0, 0, 0.55 * overlay + 0.12),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 80, 56, 120),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(48, 44, 48, 44),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22 + 0.28 * overlay),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: _stackedCopy(
                    data: data,
                    settings: settings,
                    layout: layout,
                    pair: pair,
                    lemmaColor: lemmaColor,
                    bodyColor: bodyColor,
                    lemmaSize: 96 * settings.lemmaFontScale,
                    align: CrossAxisAlignment.start,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KutipanCard extends StatelessWidget {
  const _KutipanCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final overlay = settings.overlayStrength.clamp(0.0, 1.0);
    final gradient = settings.gradientId.colors;

    return Stack(
      fit: StackFit.expand,
      children: [
        _photoOrGradient(
          imageProvider: imageProvider,
          gradient: gradient,
          videoUrl: videoUrl,
          videoIsFile: videoIsFile,
          transparentBackdrop: transparentBackdrop,
        ),
        ColoredBox(
          color: Color.fromRGBO(0, 0, 0, 0.35 * overlay + 0.28),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 160, 72, 160),
          child: Column(
            children: [
              Text(
                '"',
                style: _lemmaStyle(
                  pair: pair,
                  size: 160,
                  color: lemmaColor.withValues(alpha: 0.55),
                ).copyWith(height: 0.7),
              ),
              const Spacer(),
              _laidOut(
                id: ShareTextElementId.lemma,
                settings: settings,
                layout: layout,
                child: Text(
                  data.lemma,
                  textAlign: TextAlign.center,
                  style: _lemmaStyle(
                    pair: pair,
                    size: 108 * settings.lemmaFontScale,
                    color: lemmaColor,
                  ),
                ),
              ),
              if (settings.showPadanan &&
                  data.padanan != null &&
                  data.padanan!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _laidOut(
                  id: ShareTextElementId.padanan,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    data.padanan!,
                    textAlign: TextAlign.center,
                    style: _bodyStyle(
                      pair: pair,
                      size: 42 * settings.bodyFontScale,
                      color: lemmaColor,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              if (settings.showDefinition &&
                  data.definition != null &&
                  data.definition!.isNotEmpty) ...[
                const SizedBox(height: 28),
                _laidOut(
                  id: ShareTextElementId.definition,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    data.definition!,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    style: _bodyStyle(
                      pair: pair,
                      size: 34 * settings.bodyFontScale,
                      color: bodyColor,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (settings.showWordClass)
                _laidOut(
                  id: ShareTextElementId.wordClass,
                  settings: settings,
                  layout: layout,
                  child: _classPill(
                    data.wordClassName,
                    lemmaColor,
                    pair: pair,
                  ),
                ),
              if (settings.showExample &&
                  data.exampleSentence != null &&
                  data.exampleSentence!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _laidOut(
                  id: ShareTextElementId.example,
                  settings: settings,
                  layout: layout,
                  child: Text(
                    '"${data.exampleSentence}"',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: _bodyStyle(
                      pair: pair,
                      size: 28 * settings.bodyFontScale,
                      color: bodyColor.withValues(alpha: 0.9),
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

class _KartuCard extends StatelessWidget {
  const _KartuCard({
    required this.data,
    required this.settings,
    required this.layout,
    this.imageProvider,
    this.videoUrl,
    this.videoIsFile = false,
    this.transparentBackdrop = false,
  });

  final ShareCardData data;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;
  final String? videoUrl;
  final bool videoIsFile;
  final bool transparentBackdrop;
  final _LayoutCallbacks layout;

  @override
  Widget build(BuildContext context) {
    final pair = settings.fontPair;
    final dark = settings.textColorId.prefersDarkSurface;
    final paper = dark ? const Color(0xFF1C1917) : const Color(0xFFFFFBF5);
    final lemmaColor = settings.textColorId.lemma;
    final bodyColor = settings.textColorId.body;
    final gradient = settings.gradientId.colors;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: paper,
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: ClipRect(
                  child: _photoOrGradient(
                    imageProvider: imageProvider,
                    gradient: gradient,
                    videoUrl: videoUrl,
                    videoIsFile: videoIsFile,
                    transparentBackdrop: transparentBackdrop,
                  ),
                ),
              ),
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(64, 48, 64, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (settings.showWordClass)
                        _laidOut(
                          id: ShareTextElementId.wordClass,
                          settings: settings,
                          layout: layout,
                          child: _classPill(
                            data.wordClassName,
                            lemmaColor,
                            pair: pair,
                          ),
                        ),
                      const SizedBox(height: 20),
                      _laidOut(
                        id: ShareTextElementId.lemma,
                        settings: settings,
                        layout: layout,
                        child: Text(
                          data.lemma,
                          style: _lemmaStyle(
                            pair: pair,
                            size: 92 * settings.lemmaFontScale,
                            color: lemmaColor,
                          ),
                        ),
                      ),
                      if (settings.showPadanan &&
                          data.padanan != null &&
                          data.padanan!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _laidOut(
                          id: ShareTextElementId.padanan,
                          settings: settings,
                          layout: layout,
                          child: Text(
                            data.padanan!,
                            style: _bodyStyle(
                              pair: pair,
                              size: 36 * settings.bodyFontScale,
                              color: lemmaColor,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Container(
                        height: 2,
                        color: bodyColor.withValues(alpha: 0.22),
                      ),
                      const SizedBox(height: 24),
                      if (settings.showDefinition &&
                          data.definition != null &&
                          data.definition!.isNotEmpty)
                        _laidOut(
                          id: ShareTextElementId.definition,
                          settings: settings,
                          layout: layout,
                          child: Text(
                            data.definition!,
                            maxLines: 6,
                            style: _bodyStyle(
                              pair: pair,
                              size: 36 * settings.bodyFontScale,
                              color: bodyColor,
                            ),
                          ),
                        ),
                      if (settings.showExample &&
                          data.exampleSentence != null &&
                          data.exampleSentence!.isNotEmpty) ...[
                        const Spacer(),
                        _laidOut(
                          id: ShareTextElementId.example,
                          settings: settings,
                          layout: layout,
                          child: Text(
                            data.exampleSentence!,
                            maxLines: 3,
                            style: _bodyStyle(
                              pair: pair,
                              size: 28 * settings.bodyFontScale,
                              color: bodyColor.withValues(alpha: 0.85),
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (settings.showWatermark)
          Positioned(
            right: 48,
            bottom: 48,
            child: _watermark(data: data, pair: pair),
          ),
      ],
    );
  }
}

Widget _stackedCopy({
  required ShareCardData data,
  required ShareEditorSettings settings,
  required _LayoutCallbacks layout,
  required ShareFontPair pair,
  required Color lemmaColor,
  required Color bodyColor,
  required double lemmaSize,
  required CrossAxisAlignment align,
}) {
  return Column(
    crossAxisAlignment: align,
    children: [
      if (settings.showWordClass)
        _laidOut(
          id: ShareTextElementId.wordClass,
          settings: settings,
          layout: layout,
          child: _classPill(data.wordClassName, lemmaColor, pair: pair),
        ),
      const Spacer(),
      _laidOut(
        id: ShareTextElementId.lemma,
        settings: settings,
        layout: layout,
        child: Text(
          data.lemma,
          style: _lemmaStyle(pair: pair, size: lemmaSize, color: lemmaColor),
        ),
      ),
      if (settings.showPadanan &&
          data.padanan != null &&
          data.padanan!.isNotEmpty) ...[
        const SizedBox(height: 14),
        _laidOut(
          id: ShareTextElementId.padanan,
          settings: settings,
          layout: layout,
          child: Text(
            data.padanan!,
            style: _bodyStyle(
              pair: pair,
              size: 38 * settings.bodyFontScale,
              color: lemmaColor,
            ),
          ),
        ),
      ],
      if (settings.showDefinition &&
          data.definition != null &&
          data.definition!.isNotEmpty) ...[
        const SizedBox(height: 20),
        _laidOut(
          id: ShareTextElementId.definition,
          settings: settings,
          layout: layout,
          child: Text(
            data.definition!,
            maxLines: 5,
            style: _bodyStyle(
              pair: pair,
              size: 32 * settings.bodyFontScale,
              color: bodyColor,
            ),
          ),
        ),
      ],
      if (settings.showExample &&
          data.exampleSentence != null &&
          data.exampleSentence!.isNotEmpty) ...[
        const SizedBox(height: 16),
        _laidOut(
          id: ShareTextElementId.example,
          settings: settings,
          layout: layout,
          child: Text(
            data.exampleSentence!,
            maxLines: 3,
            style: _bodyStyle(
              pair: pair,
              size: 26 * settings.bodyFontScale,
              color: bodyColor.withValues(alpha: 0.85),
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      const Spacer(),
    ],
  );
}

