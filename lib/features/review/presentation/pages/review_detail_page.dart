import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../../domain/review_access.dart';
import '../providers/review_providers.dart';
import '../widgets/review_entity_preview.dart';
import 'review_forbidden_page.dart';

class ReviewDetailPage extends ConsumerStatefulWidget {
  const ReviewDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends ConsumerState<ReviewDetailPage> {
  bool _busy = false;

  Future<void> _approve(ReviewDetail detail) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref
        .read(reviewRepositoryProvider)
        .approve(detail.contribution.id);
    if (!mounted) return;
    setState(() => _busy = false);
    result.match((failure) => _onFailure(failure), (decision) {
      final merged = decision.mergedIntoWordId != null;
      AnalyticsService.instance.log(
        AnalyticsEvents.reviewApprove,
        params: {'contribution_id': detail.contribution.id},
      );
      _done(
        merged
            ? 'Disetujui. Makna digabung ke kata yang sudah tayang.'
            : 'Usulan disetujui.',
      );
    });
  }

  Future<void> _reject(ReviewDetail detail) async {
    if (_busy) return;
    final comment = await _askRejectReason();
    if (comment == null || !mounted) return;
    setState(() => _busy = true);
    final result = await ref
        .read(reviewRepositoryProvider)
        .reject(detail.contribution.id, comment: comment);
    if (!mounted) return;
    setState(() => _busy = false);
    result.match((failure) => _onFailure(failure), (_) {
      AnalyticsService.instance.log(
        AnalyticsEvents.reviewReject,
        params: {'contribution_id': detail.contribution.id},
      );
      _done('Usulan ditolak.');
    });
  }

  Future<String?> _askRejectReason() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => const _RejectReasonSheet(),
    );
  }

  void _onFailure(ReviewFailure failure) {
    if (failure.isForbidden) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewForbiddenPage(message: failure.message),
        ),
      );
      return;
    }
    if (failure.isAlreadyDecided) {
      showFToast(
        context: context,
        title: const Text('Usulan ini sudah diproses'),
        description: Text(failure.message),
      );
      ref.read(reviewQueueProvider(const ReviewQueueQuery()).notifier).drop(widget.id);
      invalidateReviewQueue(ref);
      context.pop();
      return;
    }
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
  }

  void _done(String message) {
    ref.read(reviewQueueProvider(const ReviewQueueQuery()).notifier).drop(widget.id);
    invalidateReviewQueue(ref);
    showFToast(context: context, title: Text(message));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(reviewDetailProvider(widget.id));
    final failure = detailAsync.hasError ? detailAsync.error : null;
    if (failure is ReviewFailure && failure.isForbidden) {
      return ReviewForbiddenPage(message: failure.message);
    }
    final pending = detailAsync.asData?.value.contribution.isPending ?? false;

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Detail usulan'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: pending
          ? detailAsync.maybeWhen(
              data: (detail) => _ReviewActionBar(
                busy: _busy,
                canCorrect: detail.contribution.entityType != 'meaning',
                onApprove: () => _approve(detail),
                onCorrect: () =>
                    context.push('/review/${detail.contribution.id}/correct'),
                onReject: () => _reject(detail),
              ),
              orElse: () => null,
            )
          : null,
      child: detailAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) {
          return Center(
            child: Text(
              error is ReviewFailure ? error.message : 'Gagal memuat detail',
            ),
          );
        },
        data: (detail) {
          final item = detail.contribution;
          final when = formatDateTimeIso(item.createdAt);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                item.title,
                style: context.theme.typography.xl.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: FLucideIcons.layers,
                    label: reviewEntityLabel(item.entityType),
                  ),
                  _MetaChip(
                    icon: FLucideIcons.user,
                    label: item.contributorUsername ?? 'anonim',
                  ),
                  if (when.isNotEmpty)
                    _MetaChip(icon: FLucideIcons.clock, label: when),
                ],
              ),
              if (detail.wordAlreadyVerified) ...[
                const Gap(14),
                FAlert(
                  title: Text(
                    detail.verifierUsername == null
                        ? 'Sudah terverifikasi. Menyetujui hanya menutup antrean.'
                        : 'Sudah terverifikasi oleh @${detail.verifierUsername}. Menyetujui hanya menutup antrean.',
                  ),
                ),
              ],
              const Gap(18),
              ReviewEntityPreview(detail: detail),
              if (!item.isPending &&
                  (detail.reviewComment?.trim().isNotEmpty ?? false)) ...[
                const Gap(16),
                _SectionNote(
                  title: 'Catatan verifikator',
                  body: detail.reviewComment!,
                ),
              ],
              if (item.isPending) ...[
                const Gap(16),
                Text(
                  'Periksa isi usulan dengan saksama sebelum memutuskan.',
                  style: context.theme.typography.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet();

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Gap(16),
          Text(
            'Tolak usulan',
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(4),
          Text(
            'Berikan alasan yang jelas agar kontributor bisa memperbaiki.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FTextField(
            control: FTextFieldControl.managed(controller: _controller),
            label: const Text('Alasan penolakan'),
            hint: 'Contoh: definisi kurang tepat / gambar tidak relevan',
            maxLines: 4,
            autofocus: true,
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: FButton(
                  variant: .outline,
                  onPress: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
              const Gap(10),
              Expanded(
                child: FButton(
                  variant: .destructive,
                  onPress: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    Navigator.pop(context, text);
                  },
                  child: const Text('Tolak'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colors.mutedForeground),
            const Gap(6),
            Text(
              label,
              style: theme.typography.xs.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNote extends StatelessWidget {
  const _SectionNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(6),
            Text(body, style: theme.typography.sm),
          ],
        ),
      ),
    );
  }
}

/// Sticky action bar: Setujui primer, Koreksi + Tolak sekunder.
class _ReviewActionBar extends StatelessWidget {
  const _ReviewActionBar({
    required this.busy,
    required this.canCorrect,
    required this.onApprove,
    required this.onCorrect,
    required this.onReject,
  });

  final bool busy;
  final bool canCorrect;
  final VoidCallback onApprove;
  final VoidCallback onCorrect;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FButton(
                onPress: busy ? null : onApprove,
                prefix: busy
                    ? const FCircularProgress()
                    : const Icon(FLucideIcons.check),
                child: Text(busy ? 'Memproses…' : 'Setujui usulan'),
              ),
              const Gap(8),
              Row(
                children: [
                  if (canCorrect) ...[
                    Expanded(
                      child: FButton(
                        variant: .outline,
                        onPress: busy ? null : onCorrect,
                        prefix: const Icon(FLucideIcons.pencil),
                        child: const Text('Koreksi'),
                      ),
                    ),
                    const Gap(8),
                  ],
                  Expanded(
                    child: FButton(
                      variant: .destructive,
                      onPress: busy ? null : onReject,
                      prefix: const Icon(FLucideIcons.x),
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
