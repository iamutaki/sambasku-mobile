import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/utils/file_persist_helper.dart';
import '../../../../shared/utils/permission_helper.dart';
import '../../dictionary/domain/entities/word_detail.dart';
import '../data/share_background_repository.dart';
import '../domain/share_models.dart';
import 'share_card_renderer.dart';
import 'share_fullscreen.dart';
import 'share_image_explorer_sheet.dart';
import 'widgets/share_card_canvas.dart';

/// Buka sheet share kartu dari detail kata.
Future<void> showWordShareSheet(
  BuildContext context, {
  required WordDetail detail,
  required ShareBackgroundRepository backgrounds,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _WordShareSheetBody(detail: detail, backgrounds: backgrounds);
    },
  );
}

String buildUnsplashQuery(WordDetail detail, WordMeaning meaning) {
  final padanan = pickPadanan(meaning) ?? '';
  final category = detail.categories.isNotEmpty
      ? detail.categories.first.name
      : '';
  final parts = [padanan, category]
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'indonesia culture';
  return parts.join(' ');
}

String? pickPadanan(WordMeaning meaning) {
  final direct = meaning.translations.where((t) => t.type == 'direct');
  if (direct.isNotEmpty) return direct.first.text;
  if (meaning.translations.isNotEmpty) return meaning.translations.first.text;
  return null;
}

ShareCardData buildCardData({
  required WordDetail detail,
  required WordMeaning meaning,
  required ShareEditorSettings settings,
  String? photographer,
}) {
  return ShareCardData(
    lemma: detail.lemma,
    wordClassName: meaning.wordClassName,
    definition: meaning.definition,
    padanan: pickPadanan(meaning),
    exampleSentence: settings.showExample && meaning.examples.isNotEmpty
        ? meaning.examples.first.sourceSentence
        : null,
    photographer: photographer,
  );
}

class _WordShareSheetBody extends StatefulWidget {
  const _WordShareSheetBody({
    required this.detail,
    required this.backgrounds,
  });

  final WordDetail detail;
  final ShareBackgroundRepository backgrounds;

  @override
  State<_WordShareSheetBody> createState() => _WordShareSheetBodyState();
}

class _WordShareSheetBodyState extends State<_WordShareSheetBody> {
  final GlobalKey _repaintKey = GlobalKey();

  late int _meaningIndex;
  ShareTemplateId _template = ShareTemplateId.unsplash;
  ShareRatioId _ratio = ShareRatioId.story;
  ShareEditorSettings _settings = const ShareEditorSettings();
  ShareBgSource _bgSource = ShareBgSource.unsplash;

  bool _loadingBg = true;
  bool _sharing = false;
  bool _saving = false;
  bool _degraded = false;
  List<ShareBackground> _bgItems = const [];
  int? _selectedBgIndex;
  File? _localImageFile;
  String? _wordImageUrl;

  WordMeaning get _meaning {
    final meanings = widget.detail.meanings;
    if (meanings.isEmpty) {
      return const WordMeaning(id: '', orderIndex: 0);
    }
    final i = _meaningIndex.clamp(0, meanings.length - 1);
    return meanings[i];
  }

  List<WordImage> get _wordImages {
    final images = [...widget.detail.images];
    images.sort((a, b) {
      if (a.isPrimary == b.isPrimary) return 0;
      return a.isPrimary ? -1 : 1;
    });
    return images;
  }

  ImageProvider? get _imageProvider {
    if (_template.forcesNoPhoto || _bgSource == ShareBgSource.none) {
      return null;
    }
    switch (_bgSource) {
      case ShareBgSource.device:
        final f = _localImageFile;
        return f != null ? FileImage(f) : null;
      case ShareBgSource.wordImage:
        final u = _wordImageUrl;
        return u != null && u.isNotEmpty ? NetworkImage(u) : null;
      case ShareBgSource.unsplash:
        final i = _selectedBgIndex;
        if (i == null || i < 0 || i >= _bgItems.length) return null;
        return NetworkImage(_bgItems[i].url);
      case ShareBgSource.none:
        return null;
    }
  }

  String? get _photographer {
    if (_bgSource != ShareBgSource.unsplash) return null;
    final i = _selectedBgIndex;
    if (i == null || i < 0 || i >= _bgItems.length) return null;
    final name = _bgItems[i].photographer;
    return name.isEmpty ? null : name;
  }

  ShareCardData get _cardData => buildCardData(
    detail: widget.detail,
    meaning: _meaning,
    settings: _settings,
    photographer: _photographer,
  );

  @override
  void initState() {
    super.initState();
    final meanings = widget.detail.meanings;
    if (meanings.isEmpty) {
      _meaningIndex = 0;
    } else {
      var best = 0;
      for (var i = 1; i < meanings.length; i++) {
        if (meanings[i].orderIndex < meanings[best].orderIndex) best = i;
      }
      _meaningIndex = best;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBackgrounds(1));
  }

  Future<void> _loadBackgrounds(int page) async {
    setState(() => _loadingBg = true);
    final q = buildUnsplashQuery(widget.detail, _meaning);
    final result = await widget.backgrounds.listBackgrounds(
      q,
      page: page,
      sort: 'relevant',
      limit: 3,
    );
    if (!mounted) return;

    setState(() {
      _loadingBg = false;
      _degraded = result.degraded;
      if (result.items.isEmpty) {
        _bgItems = const [];
        _selectedBgIndex = null;
        if (_bgSource == ShareBgSource.unsplash) {
          _bgSource = ShareBgSource.none;
        }
      } else {
        _bgItems = result.items;
        _selectedBgIndex = 0;
        if (!_template.forcesNoPhoto && _bgSource == ShareBgSource.none) {
          _bgSource = ShareBgSource.unsplash;
        }
      }
    });

    if (result.degraded && mounted) {
      showFToast(
        context: context,
        title: const Text('Foto Unsplash tidak tersedia — pakai tanpa foto'),
      );
    }
  }

  Future<void> _openImageExplorer() async {
    if (_template.forcesNoPhoto) return;
    final selected = await showShareImageExplorer(
      context,
      backgrounds: widget.backgrounds,
    );
    if (!mounted || selected == null) return;
    setState(() {
      final existing = _bgItems.indexWhere((e) => e.url == selected.url);
      if (existing >= 0) {
        _selectedBgIndex = existing;
      } else {
        _bgItems = [selected, ..._bgItems];
        _selectedBgIndex = 0;
      }
      _bgSource = ShareBgSource.unsplash;
      _localImageFile = null;
      _wordImageUrl = null;
    });
  }

  Future<void> _pickFromSource(ImageSource source) async {
    if (_template.forcesNoPhoto) return;
    final picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) showPermissionDeniedDialog(context);
          return;
        }
      }
      final picked = await picker.pickImage(source: source);
      if (picked == null || !mounted) return;
      final persisted = await copyToUniqueTempPath(File(picked.path));
      if (!mounted) return;
      setState(() {
        _localImageFile = persisted;
        _bgSource = ShareBgSource.device;
        _wordImageUrl = null;
      });
    } catch (e, st) {
      debugPrint('[SharePick] $e\n$st');
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(
          source == ImageSource.camera
              ? 'Gagal membuka kamera'
              : 'Gagal memilih dari galeri',
        ),
        variant: FToastVariant.destructive,
      );
    }
  }

  Future<void> _onShare() async {
    if (_sharing || _saving) return;
    setState(() => _sharing = true);
    try {
      final provider = _imageProvider;
      if (provider is NetworkImage) {
        await precacheImage(provider, context);
      } else if (provider is FileImage) {
        await precacheImage(provider, context);
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : const Rect.fromLTWH(0, 0, 1, 1);
      await shareCardAsPng(
        repaintKey: _repaintKey,
        caption: _cardData.caption,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text('Gagal membagikan: $e'),
        variant: FToastVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _onSave() async {
    if (_saving || _sharing) return;
    setState(() => _saving = true);
    try {
      final provider = _imageProvider;
      if (provider is NetworkImage) {
        await precacheImage(provider, context);
      } else if (provider is FileImage) {
        await precacheImage(provider, context);
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;

      final saved = await saveCardToGallery(repaintKey: _repaintKey);
      if (!mounted) return;
      if (!saved) {
        showPermissionDeniedDialog(context);
        return;
      }
      showFToast(
        context: context,
        title: const Text('Tersimpan di galeri'),
      );
    } on GalException catch (e) {
      if (!mounted) return;
      if (e.type == GalExceptionType.accessDenied) {
        showPermissionDeniedDialog(context);
        return;
      }
      showFToast(
        context: context,
        title: Text('Gagal menyimpan: ${e.type.message}'),
        variant: FToastVariant.destructive,
      );
    } catch (e) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text('Gagal menyimpan: $e'),
        variant: FToastVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openLayoutEditor() async {
    final updated = await showShareLayoutEditor(
      context,
      buildData: (settings) => buildCardData(
        detail: widget.detail,
        meaning: _meaning,
        settings: settings,
        photographer: _photographer,
      ),
      template: _template,
      ratio: _ratio,
      settings: _settings,
      imageProvider: _imageProvider,
    );
    if (!mounted || updated == null) return;
    setState(() => _settings = updated);
  }

  void _openCardFullscreen() {
    showShareCardFullscreen(
      context,
      data: _cardData,
      template: _template,
      ratio: _ratio,
      settings: _settings,
      imageProvider: _imageProvider,
    );
  }

  void _openImageFullscreen(ImageProvider image) {
    showShareImageFullscreen(context, image: image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);
    final chipSelected = theme.colors.primary;
    final chipFg = theme.colors.primaryForeground;
    final chipBg = theme.colors.secondary;
    final chipMuted = theme.colors.mutedForeground;

    Widget styleChip({
      required String label,
      required bool selected,
      required ValueChanged<bool> onSelected,
    }) {
      return FilterChip(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        label: Text(
          label,
          style: theme.typography.sm.copyWith(
            color: selected ? chipFg : theme.colors.foreground,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
        selected: selected,
        onSelected: onSelected,
        selectedColor: chipSelected,
        backgroundColor: chipBg,
        checkmarkColor: chipFg,
        side: BorderSide(
          color: selected ? chipSelected : theme.colors.border,
        ),
      );
    }

    Widget labeledChipRow({
      required String title,
      required List<Widget> chips,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              title,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) const Gap(6),
                    chips[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    final canExplore = !_template.forcesNoPhoto;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.94,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bagikan kartu',
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            // Preview-first: ambil ruang utama
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: _openCardFullscreen,
                          child: AspectRatio(
                            aspectRatio: _ratio.width / _ratio.height,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: RepaintBoundary(
                                  key: _repaintKey,
                                  child: ShareCardCanvas(
                                    data: _cardData,
                                    template: _template,
                                    ratio: _ratio,
                                    settings: _settings,
                                    imageProvider: _imageProvider,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(
                        Icons.open_with,
                        color: theme.colors.foreground,
                      ),
                      title: Text(
                        'Atur posisi teks',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Buka fullscreen untuk geser / putar teks',
                        style: theme.typography.sm.copyWith(
                          color: chipMuted,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: chipMuted,
                      ),
                      onTap: _openLayoutEditor,
                    ),
                  ],
                ),
              ),
            ),
            // Kontrol + editor (selalu terbuka)
            Expanded(
              flex: 6,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  Text(
                    'Latar',
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  if (_loadingBg)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SizedBox(
                      height: 76,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _SourceChip(
                            label: 'Tanpa\nfoto',
                            selected: _bgSource == ShareBgSource.none ||
                                _template.forcesNoPhoto,
                            selectedBorder: chipSelected,
                            gradient: _settings.gradientId.colors,
                            onTap: () => setState(() {
                              _bgSource = ShareBgSource.none;
                            }),
                          ),
                          const Gap(8),
                          _SourceChip(
                            label: 'Galeri',
                            selected: _bgSource == ShareBgSource.device &&
                                _localImageFile != null,
                            selectedBorder: chipSelected,
                            icon: Icons.photo_outlined,
                            onTap: _template.forcesNoPhoto
                                ? null
                                : () => _pickFromSource(ImageSource.gallery),
                            onLongPress: _localImageFile != null
                                ? () => _openImageFullscreen(
                                      FileImage(_localImageFile!),
                                    )
                                : null,
                            preview: _localImageFile != null
                                ? FileImage(_localImageFile!)
                                : null,
                          ),
                          const Gap(8),
                          _SourceChip(
                            label: 'Kamera',
                            selected: false,
                            selectedBorder: chipSelected,
                            icon: Icons.camera_alt_outlined,
                            onTap: _template.forcesNoPhoto
                                ? null
                                : () => _pickFromSource(ImageSource.camera),
                          ),
                          const Gap(8),
                          for (final img in _wordImages) ...[
                            _SourceChip(
                              label: 'Kata',
                              selected: _bgSource == ShareBgSource.wordImage &&
                                  _wordImageUrl == img.url,
                              selectedBorder: chipSelected,
                              preview: NetworkImage(img.url),
                              onTap: _template.forcesNoPhoto
                                  ? null
                                  : () => setState(() {
                                      _bgSource = ShareBgSource.wordImage;
                                      _wordImageUrl = img.url;
                                      _localImageFile = null;
                                    }),
                              onLongPress: () => _openImageFullscreen(
                                NetworkImage(img.url),
                              ),
                            ),
                            const Gap(8),
                          ],
                          for (var i = 0; i < _bgItems.length; i++) ...[
                            _SourceChip(
                              label: 'Unsplash',
                              selected: _bgSource == ShareBgSource.unsplash &&
                                  _selectedBgIndex == i &&
                                  !_template.forcesNoPhoto,
                              selectedBorder: chipSelected,
                              preview: NetworkImage(_bgItems[i].url),
                              onTap: _template.forcesNoPhoto
                                  ? null
                                  : () => setState(() {
                                      _bgSource = ShareBgSource.unsplash;
                                      _selectedBgIndex = i;
                                      _localImageFile = null;
                                      _wordImageUrl = null;
                                    }),
                              onLongPress: () => _openImageFullscreen(
                                NetworkImage(_bgItems[i].url),
                              ),
                            ),
                            const Gap(8),
                          ],
                          _SourceChip(
                            label: 'Explorer',
                            selected: false,
                            selectedBorder: chipSelected,
                            icon: Icons.travel_explore,
                            onTap: canExplore ? _openImageExplorer : null,
                          ),
                        ],
                      ),
                    ),
                  if (_degraded && _bgItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Unsplash tidak tersedia. Pakai tanpa foto, galeri, kamera, atau gambar kata.',
                        style: theme.typography.sm.copyWith(color: chipMuted),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Tahan thumb untuk preview fullscreen · Explorer untuk cari foto',
                      style: theme.typography.sm.copyWith(
                        color: chipMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Gap(12),
                  labeledChipRow(
                    title: 'Gaya',
                    chips: ShareTemplateId.values.map((t) {
                      return styleChip(
                        label: t.label,
                        selected: _template == t,
                        onSelected: (_) {
                          setState(() {
                            _template = t;
                            if (t.forcesNoPhoto) {
                              _bgSource = ShareBgSource.none;
                            } else if (_bgSource == ShareBgSource.none &&
                                _bgItems.isNotEmpty) {
                              _bgSource = ShareBgSource.unsplash;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Gap(8),
                  labeledChipRow(
                    title: 'Rasio',
                    chips: ShareRatioId.values.map((r) {
                      return styleChip(
                        label: r.label,
                        selected: _ratio == r,
                        onSelected: (_) => setState(() => _ratio = r),
                      );
                    }).toList(),
                  ),
                  if (widget.detail.meanings.length > 1) ...[
                    const Gap(8),
                    labeledChipRow(
                      title: 'Makna',
                      chips: [
                        for (var i = 0; i < widget.detail.meanings.length; i++)
                          styleChip(
                            label: widget.detail.meanings[i].wordClassName ??
                                'Makna ${i + 1}',
                            selected: _meaningIndex == i,
                            onSelected: (_) {
                              setState(() => _meaningIndex = i);
                              _loadBackgrounds(1);
                            },
                          ),
                      ],
                    ),
                  ],
                  const Gap(16),
                  Text(
                    'Editor',
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  labeledChipRow(
                    title: 'Font',
                    chips: ShareFontPair.values.map((f) {
                      return styleChip(
                        label: f.label,
                        selected: _settings.fontPair == f,
                        onSelected: (_) => setState(() {
                          _settings = _settings.copyWith(fontPair: f);
                        }),
                      );
                    }).toList(),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Warna',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final c in ShareTextColorId.values) ...[
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _settings =
                                        _settings.copyWith(textColorId: c);
                                  }),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: c.lemma,
                                      border: Border.all(
                                        color: _settings.textColorId == c
                                            ? chipSelected
                                            : theme.colors.border,
                                        width: _settings.textColorId == c
                                            ? 2.5
                                            : 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Gradasi',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final g in ShareGradientId.values) ...[
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _settings =
                                        _settings.copyWith(gradientId: g);
                                  }),
                                  child: Container(
                                    width: 40,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: LinearGradient(
                                        colors: g.colors,
                                      ),
                                      border: Border.all(
                                        color: _settings.gradientId == g
                                            ? chipSelected
                                            : theme.colors.border,
                                        width: _settings.gradientId == g
                                            ? 2.5
                                            : 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text('Ukuran lemma', style: theme.typography.sm),
                  Slider(
                    value: _settings.lemmaFontScale.clamp(0.7, 1.8),
                    min: 0.7,
                    max: 1.8,
                    divisions: 5,
                    activeColor: chipSelected,
                    label: _settings.lemmaFontScale.toStringAsFixed(2),
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(lemmaFontScale: v);
                    }),
                  ),
                  Text('Ukuran teks tubuh', style: theme.typography.sm),
                  Slider(
                    value: _settings.bodyFontScale.clamp(0.7, 1.6),
                    min: 0.7,
                    max: 1.6,
                    divisions: 5,
                    activeColor: chipSelected,
                    label: _settings.bodyFontScale.toStringAsFixed(2),
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(bodyFontScale: v);
                    }),
                  ),
                  if (_template == ShareTemplateId.unsplash) ...[
                    Text('Ketebalan overlay', style: theme.typography.sm),
                    Slider(
                      value: _settings.overlayStrength,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      activeColor: chipSelected,
                      label: _settings.overlayStrength.toStringAsFixed(2),
                      onChanged: (v) => setState(() {
                        _settings = _settings.copyWith(overlayStrength: v);
                      }),
                    ),
                  ],
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Tampilkan kelas kata',
                      style: theme.typography.sm,
                    ),
                    activeThumbColor: chipSelected,
                    value: _settings.showWordClass,
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(showWordClass: v);
                    }),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Tampilkan padanan',
                      style: theme.typography.sm,
                    ),
                    activeThumbColor: chipSelected,
                    value: _settings.showPadanan,
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(showPadanan: v);
                    }),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Tampilkan definisi',
                      style: theme.typography.sm,
                    ),
                    activeThumbColor: chipSelected,
                    value: _settings.showDefinition,
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(showDefinition: v);
                    }),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Tampilkan contoh kalimat',
                      style: theme.typography.sm,
                    ),
                    activeThumbColor: chipSelected,
                    value:
                        _settings.showExample && _meaning.examples.isNotEmpty,
                    onChanged: _meaning.examples.isEmpty
                        ? null
                        : (v) => setState(() {
                            _settings = _settings.copyWith(showExample: v);
                          }),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Tampilkan watermark SambasKu',
                      style: theme.typography.sm,
                    ),
                    activeThumbColor: chipSelected,
                    value: _settings.showWatermark,
                    onChanged: (v) => setState(() {
                      _settings = _settings.copyWith(showWatermark: v);
                    }),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: 1, color: theme.colors.border),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: FButton(
                            variant: FButtonVariant.outline,
                            onPress: (_saving || _sharing) ? null : _onSave,
                            prefix: _saving ? const FCircularProgress() : null,
                            child: const Text('Simpan'),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: FButton(
                            onPress: (_sharing || _saving) ? null : _onShare,
                            prefix: _sharing ? const FCircularProgress() : null,
                            child: const Text('Bagikan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.label,
    required this.selected,
    this.onTap,
    this.onLongPress,
    this.preview,
    this.icon,
    this.gradient,
    this.selectedBorder,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ImageProvider? preview;
  final IconData? icon;
  final List<Color>? gradient;
  final Color? selectedBorder;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final border = selected
        ? (selectedBorder ?? theme.colors.primary)
        : theme.colors.border;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected ? 2.5 : 1),
            gradient: preview == null && gradient != null
                ? LinearGradient(colors: gradient!)
                : null,
            color: preview == null && gradient == null
                ? theme.colors.secondary
                : null,
            image: preview != null
                ? DecorationImage(image: preview!, fit: BoxFit.cover)
                : null,
          ),
          child: preview == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        size: 22,
                        color: gradient != null
                            ? Colors.white
                            : theme.colors.foreground,
                      ),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: gradient != null
                            ? Colors.white
                            : theme.colors.foreground,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
