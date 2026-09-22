import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/widgets/attachment_images_field.dart';
import '../../data/models/create_word_image_dto.dart';
import '../../data/providers/contribution_data_providers.dart';
import '../../domain/repositories/contribution_repository.dart';

/// Alias agar pemanggil lama (suggest edit / contribute) tetap kompilasi.
typedef ContributeImageSlot = AttachmentImageSlot;

/// Field gambar usul kata - thin wrapper di atas [AttachmentImagesField]
/// (token admin `/words`, max 3, wajib login).
class ContributeImagesField extends ConsumerWidget {
  const ContributeImagesField({
    super.key,
    required this.enabled,
    required this.images,
    required this.onChanged,
  });

  final bool enabled;
  final List<AttachmentImageSlot> images;
  final ValueChanged<List<AttachmentImageSlot>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AttachmentImagesField(
      enabled: enabled,
      maxImages: 3,
      maxSizeMb: 5,
      images: images,
      onChanged: onChanged,
      disabledHint: 'Masuk untuk lampirkan gambar (opsional).',
      disabledActionLabel: enabled ? null : 'Masuk',
      onDisabledAction: enabled
          ? null
          : () {
              context.push('/login');
            },
      upload: (File file, {required bool isPrimary}) async {
        final service = ref.read(wordImageUploadServiceProvider);
        final result = await service.uploadFile(file, isPrimary: isPrimary);
        return result.match(
          (failure) => Either.left(
            AttachmentUploadFailure(
              failure.message,
              errorCode: failure.errorCode,
            ),
          ),
          (dto) => Either.right(
            AttachmentUploadedImage(
              url: dto.url,
              providerFileId: dto.providerFileId,
              altText: dto.altText,
              isPrimary: dto.isPrimary,
            ),
          ),
        );
      },
    );
  }
}

/// Map slot siap → domain image untuk submit kata.
List<SubmitWordImage> readySubmitImages(List<AttachmentImageSlot> slots) {
  return [
    for (final s in readyAttachmentImages(slots))
      SubmitWordImage(
        url: s.url,
        providerFileId: s.providerFileId,
        altText: s.altText,
        isPrimary: s.isPrimary,
      ),
  ];
}

/// Bridge DTO lama (kalau dibutuhkan di luar wrapper).
CreateWordImageDto? contributeDtoOf(AttachmentImageSlot slot) {
  final u = slot.uploaded;
  if (u == null) return null;
  return CreateWordImageDto(
    url: u.url,
    providerFileId: u.providerFileId,
    altText: u.altText,
    isPrimary: u.isPrimary,
  );
}
