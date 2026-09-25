import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/linked_accounts_providers.dart';

class LinkedAccountsPage extends ConsumerWidget {
  const LinkedAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(linkedAccountsProvider);

    ref.listen(linkedAccountsProvider.select((s) => s.infoMessage), (_, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
    });

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Akun Terhubung'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: SafeArea(
        child: state.isLoading
            ? const Center(child: FCircularProgress())
            : ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                children: [
                  FTileGroup(
                    label: const Text('Google'),
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.link),
                        title: const Text('Google'),
                        subtitle: Text(
                          state.googleLinked
                              ? 'Terhubung — bisa dipakai untuk masuk'
                              : 'Belum terhubung',
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: TextStyle(color: context.theme.colors.destructive),
                    ),
                    const Gap(12),
                  ],
                  if (state.googleLinked)
                    FButton(
                      onPress: state.isBusy
                          ? null
                          : () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Lepas Google?'),
                                  content: const Text(
                                    'Kamu tetap bisa masuk dengan email dan password.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text('Lepas'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await ref
                                    .read(linkedAccountsProvider.notifier)
                                    .unlinkGoogle();
                              }
                            },
                      child: state.isBusy
                          ? const FCircularProgress()
                          : const Text('Lepas tautan'),
                    )
                  else
                    FButton(
                      onPress: state.isBusy
                          ? null
                          : () => ref
                                .read(linkedAccountsProvider.notifier)
                                .linkGoogle(),
                      child: state.isBusy
                          ? const FCircularProgress()
                          : const Text('Hubungkan'),
                    ),
                ],
              ),
      ),
    );
  }
}
