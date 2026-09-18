import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/theme_toggle_header_action.dart';

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              FCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FLucideIcons.fileQuestion,
                          color: theme.colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          'Usul Kata Baru',
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colors.foreground,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      'Ketemu kata Sambas atau Indonesia yang belum ada di kamus? Usulkan sekarang, nanti tim kami verifikasi.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(12),
                    FButton(
                      onPress: () => context.push('/contribute'),
                      prefix: const Icon(FLucideIcons.plusCircle),
                      child: const Text('Mulai Usul Kata'),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colors.border.withValues(alpha: 0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.clock,
                      color: theme.colors.mutedForeground,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'Limit 5 usul per jam per perangkat. Kata Anda masuk antrean verifikasi sebelum tayang.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Text(
                'Fitur lain menyusul',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              const _ComingSoonTile(
                icon: FLucideIcons.camera,
                title: 'Kontribusi Gambar',
                subtitle: 'Unggah foto contoh benda / situasi kata',
              ),
              const Gap(4),
              const _ComingSoonTile(
                icon: FLucideIcons.mic,
                title: 'Rekam Pengucapan',
                subtitle: 'Bantu pengguna lain mendengar cara pengucapan',
              ),
              const Gap(4),
              const _ComingSoonTile(
                icon: FLucideIcons.checkCircle2,
                title: 'Riwayat Usulan Saya',
                subtitle: 'Lihat status usulan Anda diterima / ditinjau',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Opacity(
      opacity: 0.65,
      child: FTile(
        prefix: Icon(icon, size: 20, color: theme.colors.mutedForeground),
        title: Text(title),
        subtitle: Text(subtitle),
        suffix: FBadge(
          variant: FBadgeVariant.secondary,
          child: const Text('Soon'),
        ),
      ),
    );
  }
}
