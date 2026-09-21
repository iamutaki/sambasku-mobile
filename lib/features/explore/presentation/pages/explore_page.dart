import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../domain/explore_category.dart';
import '../../explore_router.dart';

/// Tab Eksplorasi: hub kategori discovery Sambas.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FHeader(
          title: Text('Eksplorasi'),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              FAlert(
                title: const Text('Sasaran berikutnya SambasKu'),
                subtitle: const Text(
                  'Bukan hanya kamus. Kami menyiapkan wisata, UMKM, event, berita, dan budaya Sambas. Konten di bawah masih dalam persiapan.',
                ),
                icon: const Icon(FLucideIcons.sparkles),
              ),
              const Gap(15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Nested GridView default-nya inset MediaQuery (status bar).
                padding: EdgeInsets.zero,
                itemCount: ExploreCategory.all.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.98,
                ),
                itemBuilder: (context, index) {
                  final cat = ExploreCategory.all[index];
                  return _CategoryCard(
                    category: cat,
                    onTap: () => context.push(
                      ExploreRouter.category.path.replaceFirst(':id', cat.id),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final ExploreCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Material(
      color: theme.colors.secondary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category.icon, size: 26, color: theme.colors.primary),
                  if (category.comingSoon) ...[
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Segera hadir',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                category.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                category.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(
                  fontSize: 11,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
