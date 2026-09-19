import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../data/models/create_word_image_dto.dart';
import '../../data/providers/contribution_data_providers.dart';
import '../../domain/repositories/contribution_repository.dart';

const _maxImages = 3;
const _maxSizeMb = 5;

/// Slot gambar lokal di form usul kata (upload langsung saat dipilih).
class ContributeImageSlot {
  const ContributeImageSlot({
    required this.id,
    required this.localPath,
    this.dto,
    this.uploading = false,
    this.error = false,
  });

  final String id;
  final String localPath;
  final CreateWordImageDto? dto;
  final bool uploading;
  final bool error;

  bool get isReady => dto != null && !uploading && !error;

  ContributeImageSlot copyWith({
    CreateWordImageDto? dto,
    bool? uploading,
    bool? error,
    bool clearDto = false,
  }) {
    return ContributeImageSlot(
      id: id,
      localPath: localPath,
      dto: clearDto ? null : (dto ?? this.dto),
      uploading: uploading ?? this.uploading,
      error: error ?? this.error,
    );
  }
}

/// Field gambar opsional - hanya aktif saat auth (butuh upload-token).
class ContributeImagesField extends ConsumerStatefulWidget {
  const ContributeImagesField({
    super.key,
    required this.enabled,
    required this.images,
    required this.onChanged,
  });

  final bool enabled;
  final List<ContributeImageSlot> images;
  final ValueChanged<List<ContributeImageSlot>> onChanged;

  @override
  ConsumerState<ContributeImagesField> createState() =>
      _ContributeImagesFieldState();
}

class _ContributeImagesFieldState extends ConsumerState<ContributeImagesField> {
  final _picker = ImagePicker();
  bool _unavailable = false;

  void _openPicker() {
    if (!widget.enabled || _unavailable) return;
    if (widget.images.length >= _maxImages) {
      _toast('Maksimal $_maxImages gambar');
      return;
    }

    showImageSheetDrawer(
      context,
      picker: _picker,
      filePicker: false,
      onPicked: _handlePicked,
      onRemoved: () {
        widget.onChanged(const []);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _handlePicked(File file) async {
    if (!mounted) return;
    if (widget.images.length >= _maxImages) {
      _toast('Maksimal $_maxImages gambar');
      return;
    }

    try {
      final size = await file.length();
      if (size > _maxSizeMb * 1024 * 1024) {
        if (mounted) _toast('Gambar melebihi $_maxSizeMb MB');
        return;
      }

      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final slot = ContributeImageSlot(
        id: id,
        localPath: file.path,
        uploading: true,
      );
      final next = [...widget.images, slot];
      widget.onChanged(next);
      await _upload(
        id,
        file,
        isPrimary: widget.images.isEmpty,
        snapshot: next,
      );
    } catch (e) {
      debugPrint('[ImageSheet] contribute handle $e');
      if (mounted) _toast('Gagal memproses gambar');
    }
  }

  Future<void> _upload(
    String id,
    File file, {
    required bool isPrimary,
    required List<ContributeImageSlot> snapshot,
  }) async {
    final service = ref.read(wordImageUploadServiceProvider);
    final result = await service.uploadFile(file, isPrimary: isPrimary);

    if (!mounted) return;

    result.match(
      (failure) {
        if (failure.errorCode == 'IMAGE_UPLOAD_UNAVAILABLE') {
          setState(() => _unavailable = true);
        }
        _patch(
          id,
          (s) => s.copyWith(uploading: false, error: true, clearDto: true),
          snapshot: snapshot,
        );
        _toast(failure.message);
      },
      (dto) {
        _patch(
          id,
          (s) => s.copyWith(uploading: false, error: false, dto: dto),
          snapshot: snapshot,
        );
      },
    );
  }

  void _patch(
    String id,
    ContributeImageSlot Function(ContributeImageSlot) map, {
    List<ContributeImageSlot>? snapshot,
  }) {
    final base = snapshot ?? widget.images;
    widget.onChanged([
      for (final img in base)
        if (img.id == id) map(img) else img,
    ]);
  }

  void _remove(String id) {
    widget.onChanged([
      for (final img in widget.images)
        if (img.id != id) img,
    ]);
  }

  void _toast(String message) {
    showFToast(
      context: context,
      title: Text(message),
      variant: FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (!widget.enabled) {
      return Text(
        'Masuk ke akun untuk menyertakan gambar (opsional).',
        style: theme.typography.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      );
    }

    if (_unavailable) {
      return Text(
        'Upload gambar sementara tidak tersedia. Usulan tetap bisa dikirim tanpa gambar.',
        style: theme.typography.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final img in widget.images)
              _Thumb(slot: img, onRemove: () => _remove(img.id)),
            if (widget.images.length < _maxImages)
              FButton(
                variant: .outline,
                onPress: _openPicker,
                prefix: const Icon(FLucideIcons.imagePlus, size: 14),
                child: const Text('Tambah'),
              ),
          ],
        ),
        const Gap(4),
        Text(
          'Kamera/galeri · maks $_maxSizeMb MB · hingga $_maxImages',
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.slot, required this.onRemove});

  final ContributeImageSlot slot;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(slot.localPath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: theme.colors.muted,
                  child: Icon(
                    FLucideIcons.image,
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          if (slot.uploading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x88000000),
                child: Center(child: FCircularProgress()),
              ),
            ),
          if (slot.error)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0x88B91C1C),
                child: Icon(
                  FLucideIcons.circleAlert,
                  color: theme.colors.primaryForeground,
                  size: 20,
                ),
              ),
            ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colors.destructive,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  FLucideIcons.x,
                  size: 12,
                  color: theme.colors.primaryForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Map slot siap → domain image untuk submit.
List<SubmitWordImage> readySubmitImages(List<ContributeImageSlot> slots) {
  return [
    for (final s in slots)
      if (s.isReady && s.dto != null)
        SubmitWordImage(
          url: s.dto!.url,
          providerFileId: s.dto!.providerFileId,
          altText: s.dto!.altText,
          isPrimary: s.dto!.isPrimary,
        ),
  ];
}
