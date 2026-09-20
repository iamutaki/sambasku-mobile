import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/failures/user_profile_failure.dart';
import '../providers/user_profile_providers.dart';

/// Halaman profil publik - GET /api/v1/users/:username.
class PublicProfilePage extends ConsumerWidget {
  const PublicProfilePage({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicProfileProvider(username));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(username),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.hasError
          ? _ErrorState(
              failure: async.error is UserProfileFailure
                  ? async.error! as UserProfileFailure
                  : UserProfileFailure(async.error.toString()),
              onRetry: () => ref.invalidate(publicProfileProvider(username)),
            )
          : async.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (_, _) => const SizedBox.shrink(),
              data: (profile) => _ProfileBody(profile: profile),
            ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final roleLabel = ProfilePage.roleLabels[profile.role] ?? profile.role;
    final joined = formatDateTimeIso(profile.joinedAt);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          profile.username,
          style: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              roleLabel,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            if (profile.isVerifier)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FLucideIcons.badgeCheck,
                    size: 14,
                    color: theme.colors.primary,
                  ),
                  const Gap(4),
                  Text(
                    'Verifikator',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (joined.isNotEmpty) ...[
          const Gap(4),
          Text(
            'Bergabung $joined',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
        const Gap(20),
        FTileGroup(
          label: const Text('Aktivitas'),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.filePenLine),
              title: const Text('Kontribusi disetujui'),
              suffix: Text('${profile.contributionsApproved}'),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.badgeCheck),
              title: const Text('Verifikasi'),
              suffix: Text('${profile.verificationsDone}'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.failure, required this.onRetry});

  final UserProfileFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              failure.isNotFound
                  ? FLucideIcons.searchX
                  : FLucideIcons.circleAlert,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              failure.isNotFound
                  ? 'Pengguna tidak ditemukan'
                  : 'Gagal memuat profil',
              style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const Gap(6),
            Text(
              failure.message,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
