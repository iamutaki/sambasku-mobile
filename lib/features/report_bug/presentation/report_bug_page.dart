import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../auth/presentation/providers/auth_status_providers.dart';
import '../data/bug_report_providers.dart';
import '../domain/bug_report_models.dart';

class ReportBugPage extends HookConsumerWidget {
  const ReportBugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final description = useTextEditingController();
    useListenable(description);
    final images = useState<List<XFile>>(<XFile>[]);
    final attachmentsEnabled = useState(true);
    final submitting = useState(false);
    final errorMessage = useState<String?>(null);
    final isGuest = !(ref.watch(authStatusProvider).value?.isAuth ?? false);

    final trimmed = description.text.trim();
    final canSubmit = trimmed.length >= 10 && !submitting.value;

    Future<void> pickImages() async {
      final remaining = 4 - images.value.length;
      if (remaining <= 0) return;
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 80,
        limit: remaining,
      );
      if (picked.isEmpty) return;
      images.value = [...images.value, ...picked.take(remaining)];
    }

    Future<void> submit({bool skipImages = false}) async {
      if (!canSubmit) return;
      submitting.value = true;
      errorMessage.value = null;
      try {
        final repo = ref.read(bugReportRepositoryProvider);
        final uploader = ref.read(reportImageUploadServiceProvider);
        final uploaded = <BugReportImageRef>[];
        var hideAttachments = false;

        if (!skipImages && attachmentsEnabled.value) {
          for (final file in images.value) {
            try {
              uploaded.add(await uploader.upload(file));
            } on ImageUploadUnavailable {
              hideAttachments = true;
              attachmentsEnabled.value = false;
              break;
            } on DioException catch (e) {
              if (e.response?.statusCode == 503) {
                hideAttachments = true;
                attachmentsEnabled.value = false;
                break;
              }
              if (context.mounted) {
                showFToast(
                  context: context,
                  title: const Text('Satu gambar gagal diunggah'),
                );
              }
            } catch (_) {
              if (context.mounted) {
                showFToast(
                  context: context,
                  title: const Text('Satu gambar gagal diunggah'),
                );
              }
            }
          }
        }

        if (hideAttachments && uploaded.isEmpty && images.value.isNotEmpty) {
          submitting.value = false;
          if (!context.mounted) return;
          final sendText = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Gambar tidak bisa diunggah'),
              content: const Text(
                'Penyimpanan gambar sedang tidak tersedia. Kirim laporan tanpa lampiran?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Kirim tanpa gambar'),
                ),
              ],
            ),
          );
          if (sendText == true) {
            await submit(skipImages: true);
          }
          return;
        }

        if (!skipImages &&
            attachmentsEnabled.value &&
            images.value.isNotEmpty &&
            uploaded.isEmpty) {
          submitting.value = false;
          if (!context.mounted) return;
          final sendText = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Semua gambar gagal'),
              content: const Text(
                'Keterangan tetap bisa dikirim tanpa lampiran. Lanjutkan?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Kirim tanpa gambar'),
                ),
              ],
            ),
          );
          if (sendText == true) {
            await submit(skipImages: true);
          }
          return;
        }

        final info = await PackageInfo.fromPlatform();
        final platform = defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : defaultTargetPlatform == TargetPlatform.android
            ? 'android'
            : null;

        await repo.submit(
          description: trimmed,
          images: skipImages ? const [] : uploaded,
          appVersion: info.version,
          platform: platform,
        );

        if (!context.mounted) return;
        showFToast(
          context: context,
          title: const Text('Terima kasih, laporan kamu sudah kami terima'),
        );
        context.pop();
      } on DioException catch (e) {
        errorMessage.value = _mapDio(e);
      } catch (_) {
        errorMessage.value = 'Terjadi kesalahan, coba lagi';
      } finally {
        submitting.value = false;
      }
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Laporkan Masalah'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            if (isGuest) ...[
              const FAlert(
                title: Text('Laporan kamu dikirim tanpa akun'),
              ),
              const Gap(12),
            ],
            FTextField(
              control: .managed(controller: description),
              enabled: !submitting.value,
              label: const Text('Keterangan'),
              hint: 'Ceritakan apa yang terjadi, langkah reproduksi, dan yang kamu harapkan',
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 5,
              maxLines: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${trimmed.length}/2000',
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ),
            if (attachmentsEnabled.value) ...[
              const Gap(8),
              Text(
                'Lampiran (opsional, maks 4)',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < images.value.length; i++)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(images.value[i].path),
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: submitting.value
                                ? null
                                : () {
                                    final next = [...images.value]..removeAt(i);
                                    images.value = next;
                                  },
                            icon: const Icon(FLucideIcons.x, size: 14),
                          ),
                        ),
                      ],
                    ),
                  if (images.value.length < 4)
                    IconButton.outlined(
                      onPressed: submitting.value ? null : pickImages,
                      icon: const Icon(FLucideIcons.plus),
                    ),
                ],
              ),
            ],
            if (errorMessage.value != null) ...[
              const Gap(12),
              FAlert(
                variant: .destructive,
                title: Text(errorMessage.value!),
              ),
            ],
            const Gap(16),
            FButton(
              onPress: canSubmit ? () => submit() : null,
              prefix: submitting.value ? const FCircularProgress() : null,
              child: Text(submitting.value ? 'Mengirim...' : 'Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}

String _mapDio(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
    final message = data['message'] as String;
    if (error.response?.statusCode == 429) {
      final retry = error.response?.headers.value('retry-after');
      if (retry != null && retry.isNotEmpty) {
        return '$message Coba lagi dalam $retry detik.';
      }
    }
    return message;
  }
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => 'Koneksi lambat, coba lagi',
    DioExceptionType.connectionError => 'Tidak ada koneksi internet',
    _ => 'Terjadi kesalahan, coba lagi',
  };
}
