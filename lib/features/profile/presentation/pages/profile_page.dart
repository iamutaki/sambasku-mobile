import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../../features/auth/presentation/providers/auth_status_providers.dart';

/// Tab PROFILE. Saat sudah login: info user + tombol logout
/// (revoke refresh token, 00-api-auth.md). Saat tamu: ajakan masuk.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final authStatus = ref.watch(authStatusProvider);

    return Column(
      children: [
        const FHeader(
          title: Text('Profil'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: authStatus.when(
                loading: () => const FCircularProgress(),
                error: (_, _) => const FCircularProgress(),
                data: (status) => Column(
                  mainAxisAlignment: .center,
                  children: [
                    Icon(
                      FLucideIcons.userRound,
                      size: 56,
                      color: theme.colors.mutedForeground,
                    ),
                    const Gap(8),
                    Text(
                      status.isAuth
                          ? 'Masuk sebagai ${status.username ?? 'user'}'
                          : 'Belum masuk',
                      style: theme.typography.md.copyWith(
                        color: theme.colors.foreground,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      status.isAuth
                          ? 'Kamu dapat keluar kapan saja'
                          : 'Masuk untuk berkontribusi kata',
                      textAlign: .center,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(24),
                    if (status.isAuth)
                      FButton(
                        variant: .outline,
                        onPress: status.isLoggingOut
                            ? null
                            : () => ref
                                  .read(authStatusProvider.notifier)
                                  .logout(),
                        prefix: status.isLoggingOut
                            ? const FCircularProgress()
                            : null,
                        child: Text(status.isLoggingOut ? 'Keluar...' : 'Keluar'),
                      )
                    else
                      FButton(
                        variant: .outline,
                        onPress: () => context.go('/login'),
                        child: const Text('Masuk / Login'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}