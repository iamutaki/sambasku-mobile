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
    final listState =
        ref.watch(commentListControllerProvider(widget.wordId)).value;
    final count = listState?.items.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'KOMENTAR',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.06,
                color: theme.colors.mutedForeground,
                fontSize: 11,
              ),
            ),
            if (count > 0) ...[
              const Gap(6),
              Text(
                '$count',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        const Gap(8),
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
                    Text(
                      'Belum ada komentar.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    )
                  else
                    ...state.items.map((c) {
                      final canDelete = auth != null &&
                          (c.isOwner(auth.userId) || _isVerifier(auth.role));
                      return _CommentRow(
                        comment: c,
                        dateLabel: _formatDate(c.createdAt),
                        onVote: (value) => _toggleVote(c, value),
                        onDelete: canDelete ? () => _deleteComment(c) : null,
                      );
                    }),
                  if (state.hasMore) ...[
                    const Gap(4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FButton(
                        variant: FButtonVariant.ghost,
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
                              : 'Muat lainnya',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        const Gap(10),
        if (!isAuth)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Masuk untuk menulis komentar',
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

class _CommentRow extends StatelessWidget {
  const _CommentRow({
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
    final meta = [
      comment.username ?? 'Pengguna terhapus',
      if (dateLabel.isNotEmpty) dateLabel,
      if (isPending) 'menunggu moderasi',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meta,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDelete != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        FLucideIcons.trash,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(2),
          Text(comment.body, style: theme.typography.sm.copyWith(height: 1.35)),
          const Gap(4),
          VoteButtons(
            upvotes: comment.upvotes,
            downvotes: comment.downvotes,
            myVote: comment.myVote,
            onVote: onVote,
            compact: true,
          ),
        ],
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
          hint: 'Tulis komentar…',
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 1,
        ),
        const Gap(6),
        Align(
          alignment: Alignment.centerRight,
          child: FButton(
            onPress: isSubmitting ? null : onSubmit,
            prefix: isSubmitting ? const FCircularProgress() : null,
            child: Text(isSubmitting ? 'Mengirim...' : 'Kirim'),
          ),
        ),
      ],
    );
  }
}

class _CommentsSkeleton extends StatelessWidget {
  const _CommentsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 2; i++) ...[
            Text(
              'nama · 1 Jan 2026',
              style: theme.typography.sm.copyWith(fontSize: 11),
            ),
            const Gap(2),
            Text(
              'isi komentar skeleton beberapa kata',
              style: theme.typography.sm,
            ),
            const Gap(4),
            const VoteButtonsSkeleton(compact: true),
            const Gap(10),
          ],
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
