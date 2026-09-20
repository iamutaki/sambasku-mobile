import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../flavors.dart';

/// Halaman About: identitas app + versi + deskripsi singkat.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Tentang'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: SafeArea(
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final info = snapshot.data;
            final versionLabel = info == null
                ? '…'
                : '${info.version} (${info.buildNumber})';

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Center(
                  child: Column(
                    children: [
                      const BrandLogo(size: 140),
                      const Gap(12),
                      Text(
                        F.title,
                        style: theme.typography.xl.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colors.foreground,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Kamus Digital Sambas-Indonesia',
                        textAlign: TextAlign.center,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        'Versi $versionLabel',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                _AboutBlock(
                  title: 'Apa itu SambasKu?',
                  body:
                      'Kamus komunitas untuk mencari dan mengusulkan kosakata '
                      'Sambas serta terjemahannya ke bahasa Indonesia.',
                ),
                const Gap(16),
                _AboutBlock(
                  title: 'Kontribusi',
                  body:
                      'Warga bisa mengusulkan kata baru. Usulan masuk antrean '
                      'verifikasi sebelum ditayangkan di kamus.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        Text(
          body,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
