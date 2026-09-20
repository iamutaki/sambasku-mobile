import 'package:flutter/material.dart';

import '../domain/share_models.dart';
import 'widgets/share_card_canvas.dart';

Future<void> showShareImageFullscreen(
  BuildContext context, {
  required ImageProvider image,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenImagePage(image: image),
    ),
  );
}

Future<void> showShareCardFullscreen(
  BuildContext context, {
  required ShareCardData data,
  required ShareTemplateId template,
  required ShareRatioId ratio,
  required ShareEditorSettings settings,
  ImageProvider? imageProvider,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenCardPage(
        data: data,
        template: template,
        ratio: ratio,
        settings: settings,
        imageProvider: imageProvider,
      ),
    ),
  );
}

/// Editor posisi teks fullscreen. Mengembalikan settings baru jika user tap Selesai.
Future<ShareEditorSettings?> showShareLayoutEditor(
  BuildContext context, {
  required ShareCardData Function(ShareEditorSettings settings) buildData,
  required ShareTemplateId template,
  required ShareRatioId ratio,
  required ShareEditorSettings settings,
  ImageProvider? imageProvider,
}) {
  return Navigator.of(context).push<ShareEditorSettings>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _LayoutEditorPage(
        buildData: buildData,
        template: template,
        ratio: ratio,
        initialSettings: settings,
        imageProvider: imageProvider,
      ),
    ),
  );
}

class _FullscreenImagePage extends StatelessWidget {
  const _FullscreenImagePage({required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image(image: image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _FullscreenCardPage extends StatelessWidget {
  const _FullscreenCardPage({
    required this.data,
    required this.template,
    required this.ratio,
    required this.settings,
    this.imageProvider,
  });

  final ShareCardData data;
  final ShareTemplateId template;
  final ShareRatioId ratio;
  final ShareEditorSettings settings;
  final ImageProvider? imageProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Preview kartu'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3,
          child: AspectRatio(
            aspectRatio: ratio.width / ratio.height,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ShareCardCanvas(
                data: data,
                template: template,
                ratio: ratio,
                settings: settings,
                imageProvider: imageProvider,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LayoutEditorPage extends StatefulWidget {
  const _LayoutEditorPage({
    required this.buildData,
    required this.template,
    required this.ratio,
    required this.initialSettings,
    this.imageProvider,
  });

  final ShareCardData Function(ShareEditorSettings settings) buildData;
  final ShareTemplateId template;
  final ShareRatioId ratio;
  final ShareEditorSettings initialSettings;
  final ImageProvider? imageProvider;

  @override
  State<_LayoutEditorPage> createState() => _LayoutEditorPageState();
}

class _LayoutEditorPageState extends State<_LayoutEditorPage> {
  late ShareEditorSettings _settings;
  ShareTextElementId? _selected;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  void _onPan(ShareTextElementId id, Offset canvasDelta) {
    final current = _settings.layoutFor(id);
    setState(() {
      _selected = id;
      _settings = _settings.withLayout(
        id,
        current.copyWith(offset: current.offset + canvasDelta),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.buildData(_settings);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Atur posisi teks'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Batal',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_settings),
            child: const Text(
              'Selesai',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Geser teks bertanda border · ketuk untuk pilih · putar di bawah',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.ratio.width / widget.ratio.height,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    clipBehavior: Clip.none,
                    child: ShareCardCanvas(
                      data: data,
                      template: widget.template,
                      ratio: widget.ratio,
                      settings: _settings,
                      imageProvider: widget.imageProvider,
                      layoutEditMode: true,
                      selectedElement: _selected,
                      onSelectElement: (id) => setState(() => _selected = id),
                      onPanElement: _onPan,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
            color: const Color(0xFF111111),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selected != null) ...[
                  Text(
                    'Rotasi ${_selected!.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: _settings
                        .layoutFor(_selected!)
                        .rotationDeg
                        .clamp(-90, 90),
                    min: -90,
                    max: 90,
                    divisions: 18,
                    activeColor: const Color(0xFF38BDF8),
                    label:
                        '${_settings.layoutFor(_selected!).rotationDeg.round()}°',
                    onChanged: (v) {
                      final id = _selected!;
                      final cur = _settings.layoutFor(id);
                      setState(() {
                        _settings = _settings.withLayout(
                          id,
                          cur.copyWith(rotationDeg: v),
                        );
                      });
                    },
                  ),
                ] else
                  Text(
                    'Pilih elemen teks di kartu untuk mengatur rotasi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() {
                      _settings = _settings.resetLayouts();
                      _selected = null;
                    }),
                    child: const Text('Reset posisi'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
