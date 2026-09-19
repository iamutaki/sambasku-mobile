import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/entities/word_comment.dart';
import '../../domain/failures/comment_failure.dart';
import '../providers/comment_providers.dart';

/// Section komentar pada detail kata (09-api-comment.md). List published
/// (terbaru dulu) + vote per komentar + composer (pre-moderation).
class WordCommentsSection extends ConsumerStatefulWidget {
  const WordCommentsSection({super.key, required this.wordId});

  final String wordId;

  @override
  ConsumerState<WordCommentsSection> createState() =>
      _WordCommentsSectionState();
}

class _WordCommentsSectionState extends ConsumerState<WordCommentsSection> {
  late final TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _bodyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  static bool _isVerifier(String? role) =>
      role == 'admin' || role == 'root' || role == 'reviewer';

  String _formatDate(String? iso) {
    final dt = DateTime.tryParse(iso ?? '');
    if (dt == null) return '';
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  bool _isAuth() => ref.read(authStatusProvider).value?.isAuth ?? false;

  void _promptLogin() {
    showFToast(
      context: context,
      title: const Text('Masuk dulu untuk berkomentar'),
      variant: FToastVariant.primary,
    );
    context.push('/login');
  }

  Future<void> _sendComment() async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final failure = await ref
        .read(commentListControllerProvider(widget.wordId).notifier)
        .create(_bodyCtrl.text);
    if (!mounted) return;
    if (failure == null) {
      _bodyCtrl.clear();
      showFToast(
        context: context,
        title: const Text('Komentar terkirim, menunggu moderasi'),
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

  Future<void> _toggleVote(WordComment comment, int value) async {
    if (!_isAuth()) {
      _promptLogin();
      return;
    }
    final failure = await ref
        .read(commentListControllerProvider(widget.wordId).notifier)
        .toggleVote(comment, value);
    if (!mounted || failure == null) return;
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
  }

  Future<void> _deleteComment(WordComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus komentar?'),
        content: const Text('Komentar ini akan disembunyikan dari semua orang.'),
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
        .read(commentListControllerProvider(widget.wordId).notifier)
        .delete(comment);
    if (!mounted) return;
    showFToast(
      context: context,
      title: Text(failure == null ? 'Komentar dihapus' : failure.message),
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

    final listState = ref
        .watch(commentListControllerProvider(widget.wordId))
        .value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              FLucideIcons.messageCircle,
              size: 18,
              color: theme.colors.primary,
            ),
            const Gap(6),
            Text(
              'Komentar',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            FBadge(
              variant: FBadgeVariant.secondary,
              child: Text('${listState?.items.length ?? 0}'),
            ),
          ],
        ),
        const Gap(12),
        ref.watch(commentListControllerProvider(widget.wordId)).when(
              loading: () => const _CommentsSkeleton(),
              error: (error, _) => _CommentsError(
                message: error is CommentFailure
                    ? error.message
                    : 'Gagal memuat komentar',
                onRetry: () =>
                    ref.invalidate(commentListControllerProvider(widget.wordId)),
              ),
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Belum ada komentar. Jadilah yang pertama.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  else
                    ...state.items.map((c) {
                      final canDelete =
                          auth != null &&
                          (c.isOwner(auth.userId) || _isVerifier(auth.role));
                      return _CommentCard(
                        comment: c,
                        dateLabel: _formatDate(c.createdAt),
                        onVote: (value) => _toggleVote(c, value),
                        onDelete: canDelete ? () => _deleteComment(c) : null,
                      );
                    }),
                  if (state.hasMore) ...[
                    const Gap(8),
                    Center(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: state.isLoadingMore
                            ? null
                            : () => ref
                                .read(
                                  commentListControllerProvider(widget.wordId)
                                      .notifier,
                                )
                                .loadMore(),
                        prefix: state.isLoadingMore
                            ? const FCircularProgress()
                            : null,
                        child: Text(
                          state.isLoadingMore
                              ? 'Memuat...'
                              : 'Muat komentar lain',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        const Gap(16),
        if (!isAuth)
          FCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Masuk untuk menulis komentar',
                    style: theme.typography.sm,
                  ),
                ),
                FButton(
                  variant: FButtonVariant.primary,
                  onPress: _promptLogin,
                  child: const Text('Masuk'),
                ),
              ],
            ),
          )
        else
          _Composer(
            controller: _bodyCtrl,
            isSubmitting: listState?.isSubmitting ?? false,
            onSubmit: _sendComment,
          ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.comment,
    required this.dateLabel,
    required this.onVote,
    this.onDelete,
  });

  final WordComment comment;
  final String dateLabel;
  final Future<void> Function(int value) onVote;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isPending = comment.status == 'pending_review';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    FLucideIcons.userRound,
                    size: 15,
                    color: theme.colors.primary,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username ?? 'Pengguna terhapus',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dateLabel.isNotEmpty)
                        Text(
                          dateLabel,
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isPending)
                  FBadge(
                    variant: FBadgeVariant.secondary,
                    child: const Text('Menunggu moderasi'),
                  ),
                if (onDelete != null)
                  // FCard forui tanpa ancestor Material - bungkus sendiri
                  // supaya InkWell (dan ripple-nya) jalan di host mana pun.
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          FLucideIcons.trash,
                          size: 15,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(8),
            Text(comment.body, style: theme.typography.sm),
            const Gap(10),
            VoteButtons(
              upvotes: comment.upvotes,
              downvotes: comment.downvotes,
              myVote: comment.myVote,
              onVote: onVote,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          control: FTextFieldControl.managed(controller: controller),
          hint: 'Tulis komentar, menunggu persetujuan tim...',
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 1,
        ),
        const Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              onPress: isSubmitting ? null : onSubmit,
              prefix: isSubmitting
                  ? const FCircularProgress()
                  : const Icon(FLucideIcons.send),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CommentsSkeleton extends StatelessWidget {
  const _CommentsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: FCard(
              child: Text('komentar skeleton baris isi komentar'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: FCard(
              child: Text('komentar kedua isi skeleton'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsError extends StatelessWidget {
  const _CommentsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FAlert(
      variant: FAlertVariant.destructive,
      title: Text(message),
      subtitle: const Text('Coba lagi untuk memuat komentar.'),
    );
  }
}