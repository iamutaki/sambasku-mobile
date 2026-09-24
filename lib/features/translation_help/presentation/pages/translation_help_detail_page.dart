import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../domain/translation_help_models.dart';
import '../providers/translation_help_list_providers.dart';

/// Detail bantuan + thread balasan.
class TranslationHelpDetailPage extends ConsumerStatefulWidget {
  const TranslationHelpDetailPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TranslationHelpDetailPage> createState() =>
      _TranslationHelpDetailPageState();
}

class _TranslationHelpDetailPageState
    extends ConsumerState<TranslationHelpDetailPage> {
  late final TextEditingController _replyCtrl;

  @override
  void initState() {
    super.initState();
    _replyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  bool _isAuth() => ref.read(authStatusProvider).value?.isAuth ?? false;

  void _promptLogin() {
    showFToast(
      context: context,
      title: const Text('Masuk dulu untuk membalas'),
      variant: FToastVariant.primary,
    );
    context.push('/login');
  }

  Future<void> _sendReply() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final failure = await ref
        .read(translationHelpDetailProvider(widget.id).notifier)
        .createReply(_replyCtrl.text);
    if (!mounted) return;
    if (failure == null) {
      _replyCtrl.clear();
      showFToast(
        context: context,
        title: const Text('Balasan terkirim'),
        variant: FToastVariant.primary,
      );
    } else {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }

  Future<void> _deleteReply(TranslationHelpReply reply) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus balasan?'),
        content: const Text('Balasan akan dihapus dari thread.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FButton(
            variant: FButtonVariant.destructive,
            onPress: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final failure = await ref
        .read(translationHelpDetailProvider(widget.id).notifier)
        .deleteReply(reply);
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(failure == null ? 'Balasan dihapus' : failure.message),
      variant: failure == null
          ? FToastVariant.primary
          : FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;
    final async = ref.watch(translationHelpDetailProvider(widget.id));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Detail Bantuan'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FLucideIcons.circleAlert,
                  size: 40,
                  color: theme.colors.mutedForeground,
                ),
                const Gap(10),
                Text(
                  error is TranslationHelpFailure
                      ? error.message
                      : 'Gagal memuat detail',
                  textAlign: TextAlign.center,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(16),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () =>
                      ref.invalidate(translationHelpDetailProvider(widget.id)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          final item = state.item;
          final canReply = item.isPublished;
          final replies = item.orderedReplies;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(translationHelpDetailProvider(widget.id));
                    await ref.read(
                      translationHelpDetailProvider(widget.id).future,
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      _HelpHeader(item: item),
                      if (item.body?.trim().isNotEmpty == true) ...[
                        const Gap(10),
                        Text(item.body!.trim(), style: theme.typography.sm),
                      ],
                      if (item.imageDisplayUrls.isNotEmpty) ...[
                        const Gap(12),
                        _ImageRow(urls: item.imageDisplayUrls),
                      ],
                      if (item.status == 'rejected' &&
                          (item.rejectionNote?.trim().isNotEmpty ?? false)) ...[
                        const Gap(12),
                        FAlert(
                          variant: FAlertVariant.destructive,
                          title: Text(item.rejectionNote!.trim()),
                        ),
                      ],
                      const Gap(16),
                      Text(
                        replies.isEmpty
                            ? 'Balasan'
                            : 'Balasan · ${replies.length}',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(8),
                      if (!canReply)
                        Text(
                          item.status == 'pending_review'
                              ? 'Balasan dibuka setelah permintaan ditayangkan.'
                              : 'Thread balasan tidak tersedia untuk status ini.',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      else if (replies.isEmpty)
                        Text(
                          'Belum ada balasan. Jadilah yang pertama membantu.',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      else
                        for (final reply in replies)
                          _ReplyRow(
                            reply: reply,
                            dateLabel: formatDateTimeIso(reply.createdAt),
                            onDelete:
                                reply.isPublished &&
                                    reply.isOwner(auth?.userId)
                                ? () => _deleteReply(reply)
                                : null,
                            onUsernameTap: isLinkablePublicUsername(
                              reply.username,
                            )
                                ? () => UserProfileRouter.open(
                                    context,
                                    reply.username!,
                                  )
                                : null,
                          ),
                    ],
                  ),
                ),
              ),
              if (canReply)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: !isAuth
                      ? Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Masuk untuk membalas',
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ),
                            FButton(
                              variant: FButtonVariant.outline,
                              onPress: _promptLogin,
                              child: const Text('Masuk'),
                            ),
                          ],
                        )
                      : _ReplyComposer(
                          controller: _replyCtrl,
                          isSubmitting: state.isSubmittingReply,
                          onSubmit: _sendReply,
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  const _HelpHeader({required this.item});

  final TranslationHelpItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final when = formatDateTimeIso(item.createdAt);
    final username = displayPublicUsername(item.username);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                username,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FBadge(
              variant: item.isPublished
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(item.statusLabel),
            ),
          ],
        ),
        if (when.isNotEmpty) ...[
          const Gap(4),
          Text(
            when,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _ImageRow extends StatelessWidget {
  const _ImageRow({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, i) {
          final src = urls[i];
          final display = displayImageUrl(src, width: 400) ?? src;
          return GestureDetector(
            onTap: () => showImagePreview(
              context,
              urls: [
                for (final u in urls) displayImageUrl(u, width: 1200) ?? u,
              ],
              initialIndex: i,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 96,
                height: 96,
                child: CachedNetworkImageWithFallback(
                  imageUrl: display,
                  fallbackUrl: src,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReplyRow extends StatelessWidget {
  const _ReplyRow({
    required this.reply,
    required this.dateLabel,
    this.onDelete,
    this.onUsernameTap,
  });

  final TranslationHelpReply reply;
  final String dateLabel;
  final VoidCallback? onDelete;
  final VoidCallback? onUsernameTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isRedacted = !reply.isPublished;
    final username = displayPublicUsername(reply.username);
    final pinned = reply.isPinned;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pinned
              ? theme.colors.secondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: pinned
              ? Border.all(color: theme.colors.primary.withValues(alpha: 0.35))
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(pinned ? 10 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        GestureDetector(
                          onTap: onUsernameTap,
                          child: Text(
                            username,
                            style: theme.typography.sm.copyWith(
                              color: onUsernameTap != null
                                  ? theme.colors.primary
                                  : theme.colors.mutedForeground,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (reply.isVerifier)
                          FBadge(
                            variant: FBadgeVariant.primary,
                            child: const Text('Verifikator'),
                          ),
                        if (pinned)
                          FBadge(
                            variant: FBadgeVariant.secondary,
                            child: const Text('Disematkan'),
                          ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: Icon(
                        FLucideIcons.trash2,
                        size: 16,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                ],
              ),
              if (dateLabel.isNotEmpty)
                Text(
                  dateLabel,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 11,
                  ),
                ),
              const Gap(4),
              Text(
                isRedacted
                    ? (reply.status == 'taken_down'
                          ? 'Balasan dihapus moderator'
                          : 'Balasan dihapus penulis')
                    : (reply.body ?? ''),
                style: theme.typography.sm.copyWith(
                  color: isRedacted
                      ? theme.colors.mutedForeground
                      : theme.colors.foreground,
                  fontStyle: isRedacted ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyComposer extends StatelessWidget {
  const _ReplyComposer({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: FTextField(
            control: FTextFieldControl.managed(controller: controller),
            enabled: !isSubmitting,
            hint: 'Tulis balasan...',
            maxLines: 3,
            minLines: 1,
          ),
        ),
        const Gap(8),
        FButton(
          onPress: isSubmitting ? null : onSubmit,
          prefix: isSubmitting ? const FCircularProgress() : null,
          child: const Text('Kirim'),
        ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Bone.text(words: 3),
          Gap(12),
          Bone.multiText(lines: 3),
          Gap(12),
          Bone(width: 96, height: 96),
          Gap(20),
          Bone.text(words: 2),
          Gap(8),
          Bone.multiText(lines: 2),
        ],
      ),
    );
  }
}
