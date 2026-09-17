import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/widgets/theme_toggle_header_action.dart';

/// Tab ACTION - placeholder. Akan menjadi pusat kontribusi:
/// usul kata (anonim/login), kontribusi media, status kontribusi
/// (roadmap mobile-base-stack Section 12 tahap 4-5).
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      children: [
        const FHeader(
          title: Text('Kontribusi'),
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
                    FLucideIcons.circlePlus,
                    size: 56,
                    color: theme.colors.mutedForeground,
                  ),
                  const Gap(8),
                  Text(
                    'Fitur kontribusi menyusul',
                    style: theme.typography.md.copyWith(
                      color: theme.colors.foreground,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Usul kata baru & kontribusi media akan hidup di sini',
                    textAlign: TextAlign.center,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
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
