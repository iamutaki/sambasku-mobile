import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../domain/explore_category.dart';

/// Placeholder konten kategori — siap diisi API nanti.
class ExploreCategoryPage extends StatelessWidget {
  const ExploreCategoryPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final category = ExploreCategory.byId(categoryId);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(category?.title ?? 'Eksplorasi'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category?.icon ?? FLucideIcons.compass,
                size: 48,
                color: theme.colors.primary,
              ),
              const Gap(16),
              Text(
                'Segera hadir',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              Text(
                category?.subtitle ??
                    'Kategori ini belum tersedia.',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(12),
              Text(
                'Kami sedang menyiapkan konten untuk menjelajahi Sambas lebih dalam.',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
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
