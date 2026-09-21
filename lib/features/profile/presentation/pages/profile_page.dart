import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../auth/presentation/models/auth_status_state.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../notification/notification_router.dart';
import '../../../notification/presentation/providers/notification_providers.dart';
import '../widgets/appearance_tiles.dart';
import '../widgets/notification_header_action.dart';

/// Tab PROFILE - identity + menu via FTileGroup.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const roleLabels = <String, String>{
    'root': 'Root',
    'admin': 'Admin',
    'editor': 'Editor',
    'reviewer': 'Reviewer',
    'contributor': 'Kontributor',
  };

  static void _comingSoon(BuildContext context, String feature) {
    showFToast(context: context, title: Text('$feature segera hadir'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);

    return Column(
      children: [
        FHeader(
          title: const Text('Profil'),
          suffixes: [
            if (authStatus.value?.isAuth ?? false)
              const NotificationHeaderAction(),
            const ThemeToggleHeaderAction(),
          ],
        ),
        Expanded(
          child: authStatus.when(
            loading: () => const Center(child: FCircularProgress()),
            error: (_, _) => const Center(child: FCircularProgress()),
            data: (status) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _IdentityTileGroup(status: status),
                const Gap(14),
                if (status.isAuth) ...[
                  FTileGroup(
                    label: const Text('Saya'),
                    children: [
                      const _NotificationTile(),
                      FTile(
                        prefix: const Icon(FLucideIcons.filePenLine),
                        title: const Text('Kontribusi Saya'),
                        subtitle: const Text('Riwayat & status usulan kata'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/contributions'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.bookmark),
                        title: const Text('Bookmark'),
                        subtitle: const Text(
                          'Kata tersimpan untuk dibaca lagi',
                        ),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/bookmarks'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.arrowBigUp),
                        title: const Text('Vote'),
                        subtitle: const Text('Kata yang pernah kamu vote'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => _comingSoon(context, 'Vote'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.messageSquare),
                        title: const Text('Komentar'),
                        subtitle: const Text('Komentar & status moderasi'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => _comingSoon(context, 'Komentar'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.flag),
                        title: const Text('Laporkan Masalah'),
                        subtitle: const Text('Kirim saran atau laporkan bug'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => _comingSoon(context, 'Laporkan Masalah'),
                      ),
                    ],
                  ),
                  const Gap(14),
                  FTileGroup(
                    label: const Text('Akun'),
                    children: [
                      if (status.role == 'contributor')
                        FTile(
                          prefix: const Icon(FLucideIcons.badgeCheck),
                          title: const Text('Jadi verifikator'),
                          subtitle: const Text(
                            'Ajukan diri untuk meninjau kontribusi',
                          ),
                          suffix: const Icon(FLucideIcons.chevronRight),
                          onPress: () => context.push('/verifier-application'),
                        ),
                      FTile(
                        prefix: const Icon(FLucideIcons.keyRound),
                        title: const Text('Ubah Password'),
                        subtitle: const Text('Ganti password akun'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.push('/change-password'),
                      ),
                    ],
                  ),
                  const Gap(14),
                ] else
                  FTileGroup(
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.logIn),
                        title: const Text('Masuk / Login'),
                        subtitle: const Text('Masuk untuk berkontribusi kata'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.go('/login'),
                      ),
                      FTile(
                        prefix: const Icon(FLucideIcons.userRoundPlus),
                        title: const Text('Daftar'),
                        subtitle: const Text('Buat akun kontributor baru'),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () => context.go('/register'),
                      ),
                    ],
                  ),
                const Gap(14),
                FTileGroup(
                  label: const Text('Tampilan'),
                  children: [themeModeTile(ref), paletteTile(ref)],
                ),
                const Gap(14),
                FTileGroup(
                  label: const Text('Tentang'),
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.info),
                      title: const Text('Tentang SambasKu'),
                      subtitle: const Text('Fitur dan versi aplikasi'),
                      suffix: const Icon(FLucideIcons.chevronRight),
                      onPress: () => context.push('/about'),
                    ),
                  ],
                ),
                if (status.isAuth) ...[
                  const Gap(14),
                  FTileGroup(
                    children: [
                      FTile(
                        variant: .destructive,
                        prefix: status.isLoggingOut
                            ? const FCircularProgress()
                            : const Icon(FLucideIcons.logOut),
                        title: Text(
                          status.isLoggingOut ? 'Keluar...' : 'Keluar',
                        ),
                        enabled: !status.isLoggingOut,
                        onPress: status.isLoggingOut
                            ? null
                            : () => ref
                                  .read(authStatusProvider.notifier)
                                  .logout(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends ConsumerWidget with FTileMixin {
  const _NotificationTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread =
        ref.watch(unreadNotificationCountControllerProvider).value ?? 0;
    return FTile(
      prefix: const Icon(FLucideIcons.bell),
      title: const Text('Notifikasi'),
      subtitle: Text(
        unread > 0 ? '$unread belum dibaca' : 'Status usulan yang sudah direview',
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(NotificationRouter.list.path),
    );
  }
}

class _IdentityTileGroup extends StatelessWidget {
  const _IdentityTileGroup({required this.status});

  final AuthStatusState status;

  @override
  Widget build(BuildContext context) {
    final username = status.username?.trim();
    final displayName = status.isAuth
        ? (username?.isNotEmpty == true ? username! : 'Pengguna')
        : 'Belum masuk';
    final roleLabel = status.isAuth && status.role != null
        ? (ProfilePage.roleLabels[status.role!] ?? status.role!)
        : null;
    final subtitle = status.isAuth
        ? (roleLabel ?? 'Kelola akun dan keamanan')
        : 'Masuk untuk berkontribusi kata';

    return FTileGroup(
      children: [
        FTile(
          prefix: _ProfileAvatar(
            name: status.isAuth ? displayName : null,
            size: 40,
          ),
          title: Text(displayName),
          subtitle: Text(subtitle),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, this.size = 40});

  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final initials = _initials(name);

    return FAvatar.raw(
      size: size,
      style: .delta(
        backgroundColor: initials != null
            ? theme.colors.primary.withValues(alpha: 0.12)
            : theme.colors.muted,
      ),
      child: initials != null
          ? Text(
              initials,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.primary,
                height: 1,
              ),
            )
          : Icon(
              FLucideIcons.userRound,
              size: size * 0.42,
              color: theme.colors.mutedForeground,
            ),
    );
  }

  static String? _initials(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final word = parts.first;
    if (word.length >= 2) return word.substring(0, 2).toUpperCase();
    return word.toUpperCase();
  }
}
