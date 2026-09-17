import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/theme_toggle_header_action.dart';

/// Tab PROFILE - placeholder. Akan menampilkan info user, logout,
/// dan pengaturan (roadmap tahap 6).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FLucideIcons.userRound,
                    size: 56,
                    color: theme.colors.mutedForeground,
                  ),
                  const Gap(8),
                  Text(
                    'Profil menyusul',
                    style: theme.typography.md.copyWith(
                      color: theme.colors.foreground,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Info user, logout, dan pengaturan akan hidup di sini',
                    textAlign: TextAlign.center,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(24),
                  FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => context.go('/login'),
                    child: const Text('Masuk / Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
