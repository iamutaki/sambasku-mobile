import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/word_detail.dart';
import '../providers/pronunciation_providers.dart';
import '../utils/ensure_microphone_ready.dart';
import 'audio_player_tile.dart';
import 'record_pronunciation_sheet.dart';

/// Daftar audio pelafalan + tombol rekam (kata atau contoh kalimat).
/// Tile selalu compact (pola contoh) + progress bar saat diputar.
class PronunciationSection extends ConsumerWidget {
  const PronunciationSection({
    super.key,
    required this.wordId,
    required this.languageId,
    required this.audios,
    this.exampleId,
    this.compact = false,
    this.sectionLabel = 'Pelafalan',
    /// Teks yang dilafalkan: lemma (audio kata). Contoh biasanya sudah
    /// punya kalimat di luar section.
    this.spokenText,
  });

  final String wordId;
  final String languageId;
  final List<WordAudio> audios;
  final String? exampleId;
  final bool compact;
  final String sectionLabel;
  final String? spokenText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadUnavailable = ref.watch(
      pronunciationUploadUnavailableProvider(wordId),
    );
    final canRecord = !uploadUnavailable;
    final sorted = sortWordAudios(audios);
    final spoken = spokenText?.trim();

    if (sorted.isEmpty && !canRecord) {
      return const SizedBox.shrink();
    }

    final dialectsAsync = ref.watch(wordDialectsProvider(languageId));
    final dialectMap = {
      for (final d in dialectsAsync.value ?? const <DialectOption>[]) d.id: d.name,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            sectionLabel,
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.06,
              color: context.theme.colors.mutedForeground,
              fontSize: 11,
            ),
          ),
          const Gap(6),
        ],
        if (spoken != null && spoken.isNotEmpty) ...[
          Text(
            spoken,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
          const Gap(4),
        ],
        if (sorted.isNotEmpty) ...[
          ...sorted.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: AudioPlayerTile(
                wordId: wordId,
                audio: a,
                dialectName: a.dialectId == null
                    ? null
                    : dialectMap[a.dialectId],
              ),
            ),
          ),
        ] else if (!compact) ...[
          Text(
            'Belum ada audio pelafalan kata',
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const Gap(6),
        ],
        if (canRecord) ...[
          if (sorted.isNotEmpty) const Gap(2),
          FButton(
            variant: FButtonVariant.ghost,
            onPress: () => _openRecord(context, ref),
            prefix: Icon(
              FLucideIcons.mic,
              size: 16,
              color: context.theme.colors.primary,
            ),
            child: Text(compact ? 'Rekam audio contoh' : 'Rekam pelafalan'),
          ),
        ],
      ],
    );
  }

  Future<void> _openRecord(BuildContext context, WidgetRef ref) async {
    final auth = await ref.read(authStatusProvider.future);
    if (!context.mounted) return;
    if (!auth.isAuth) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk rekam pelafalan'),
      );
      context.push('/login');
      return;
    }

    final micReady = await ensureMicrophoneReady(context);
    if (!context.mounted || !micReady) return;

    await showRecordPronunciationSheet(
      context,
      ref: ref,
      wordId: wordId,
      languageId: languageId,
      exampleId: exampleId,
      defaultSpeakerName: auth.username ?? '',
    );
  }
}
