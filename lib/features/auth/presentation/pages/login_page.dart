import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../../flavors.dart';
import '../providers/auth_login_providers.dart';
import '../providers/auth_status_providers.dart';

/// Halaman login (email + password). Google sign-in menyusul - backend
/// Section 23 belum diimplement. Sukses login -> router redirect ke
/// splash (isAuth sudah true).
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authLoginProvider);
    final authStatus = ref.watch(authStatusProvider);
    final alreadyAuth = authStatus.value?.isAuth ?? false;
    final email = useTextEditingController();
    final password = useTextEditingController();
    final logoLoaded = useState(false);
    useListenable(email);
    useListenable(password);

    // Sudah login → jangan tampilkan form; redirect (router juga jaga)
    ref.listen(authStatusProvider, (_, next) {
      if (next.value?.isAuth == true && context.mounted) context.go('/');
    });

    // pindah ke HOME begitu sesi tersimpan
    ref.listen(authLoginProvider.select((s) => s.session), (_, next) {
      if (next != null) context.go('/');
    });

    if (alreadyAuth) {
      return const FScaffold(
        childPad: true,
        child: Center(child: FCircularProgress()),
      );
    }

    final canSubmit = email.text.contains('@') &&
        password.text.length >= 8 &&
        !state.isSubmitting;

    void submit() => ref.read(authLoginProvider.notifier).submit(
          email: email.text,
          password: password.text,
        );

    final theme = context.theme;

    return FScaffold(
      childPad: true,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .stretch,
              children: [
                Skeletonizer(
                  enabled: !logoLoaded.value,
                  child: FractionallySizedBox(
                    widthFactor: 0.55,
                    child: BrandLogo(
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if ((wasSynchronouslyLoaded || frame != null) &&
                            !logoLoaded.value) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) logoLoaded.value = true;
                          });
                        }
                        return child;
                      },
                    ),
                  ),
                ),
                const Gap(12),
                Text(
                  F.title,
                  textAlign: .center,
                  style: theme.typography.xl2.copyWith(
                    fontWeight: .w600,
                    color: theme.colors.foreground,
                  ),
                ),
                const Gap(32),
                FTextField.email(
                  control: .managed(controller: email),
                  enabled: !state.isSubmitting,
                  label: const Text('Email'),
                ),
                const Gap(12),
                FTextField.password(
                  control: .managed(controller: password),
                  enabled: !state.isSubmitting,
                  label: const Text('Password'),
                  textInputAction: .done,
                  onSubmit: canSubmit ? (_) => submit() : null,
                ),
                if (state.errorMessage != null) ...[
                  const Gap(12),
                  FAlert(
                    variant: .destructive,
                    title: Text(state.errorMessage!),
                  ),
                ],
                const Gap(16),
                FButton(
                  onPress: canSubmit ? submit : null,
                  prefix: state.isSubmitting
                      ? const FCircularProgress()
                      : null,
                  child: Text(state.isSubmitting ? 'Memproses...' : 'Masuk'),
                ),
                const Gap(8),
                FButton(
                  variant: .ghost,
                  onPress: state.isSubmitting
                      ? null
                      : () => context.go('/register'),
                  child: const Text('Belum punya akun? Daftar'),
                ),
                const Gap(4),
                FButton(
                  variant: .ghost,
                  onPress: state.isSubmitting
                      ? null
                      : () => context.go('/'), // lanjut sebagai tamu
                  child: const Text('Lanjut tanpa login (tamu)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
