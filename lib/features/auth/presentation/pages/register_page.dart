import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth_router.dart';
import '../providers/auth_register_providers.dart';
import '../providers/auth_status_providers.dart';

/// Prefix negara di-lock dulu ke +62; nanti diganti dinamis (locale/config).
const kPhoneCountryPrefix = '+62';

/// Register sederhana: nama, email, HP opsional (+62 locked), password.
/// Auto-verify di backend (tanpa OTP) → sukses langsung login + ke home.
class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authRegisterProvider);
    final authStatus = ref.watch(authStatusProvider);
    final alreadyAuth = authStatus.value?.isAuth ?? false;
    final name = useTextEditingController();
    final email = useTextEditingController();
    final phone = useTextEditingController();
    final password = useTextEditingController();
    final confirmPassword = useTextEditingController();
    useListenable(name);
    useListenable(email);
    useListenable(phone);
    useListenable(password);
    useListenable(confirmPassword);

    // Auto-login sukses → home
    ref.listen(authStatusProvider, (_, next) {
      if (next.value?.isAuth == true && context.mounted) context.go('/');
    });

    // Register ok tapi auto-login gagal → login manual
    ref.listen(authRegisterProvider.select((s) => s.needsManualLogin), (
      _,
      needsManual,
    ) {
      if (needsManual != true || !context.mounted) return;
      showFToast(
        context: context,
        title: const Text('Akun dibuat - silakan masuk'),
      );
      context.go(AuthRouter.login.path);
    });

    if (alreadyAuth) {
      return const FScaffold(
        childPad: true,
        child: Center(child: FCircularProgress()),
      );
    }

    final passwordOk =
        password.text.length >= 8 &&
        password.text.contains(RegExp(r'[a-zA-Z]')) &&
        password.text.contains(RegExp(r'[0-9]'));
    final canSubmit =
        name.text.trim().isNotEmpty &&
        email.text.contains('@') &&
        passwordOk &&
        confirmPassword.text == password.text &&
        !state.isSubmitting;

    void submit() => ref
        .read(authRegisterProvider.notifier)
        .submit(
          name: name.text,
          email: email.text,
          phoneNationalDigits: phone.text.trim().isEmpty
              ? null
              : phone.text.trim(),
          password: password.text,
          confirmPassword: confirmPassword.text,
        );

    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Daftar'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(AuthRouter.login.path),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(
                  'Buat akun Kontributor',
                  textAlign: .center,
                  style: theme.typography.xl.copyWith(
                    fontWeight: .w600,
                    color: theme.colors.foreground,
                  ),
                ),
                const Gap(8),
                Text(
                  'Langsung aktif tanpa OTP. Setelah daftar kamu otomatis masuk.',
                  textAlign: .center,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(24),
                FTextField(
                  control: .managed(controller: name),
                  enabled: !state.isSubmitting,
                  label: const Text('Nama'),
                  textInputAction: .next,
                ),
                const Gap(12),
                FTextField.email(
                  control: .managed(controller: email),
                  enabled: !state.isSubmitting,
                  label: const Text('Email'),
                ),
                const Gap(12),
                FTextField(
                  control: .managed(controller: phone),
                  enabled: !state.isSubmitting,
                  label: const Text('No. HP (opsional)'),
                  hint: '81234567890',
                  keyboardType: .phone,
                  textInputAction: .next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // ponytail: prefix +62 di-lock dulu; nanti dinamis dari locale/config
                  prefixBuilder: (context, style, variants) => Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Text(
                      kPhoneCountryPrefix,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                FTextField.password(
                  control: .managed(controller: password),
                  enabled: !state.isSubmitting,
                  label: const Text('Password'),
                  hint: 'Minimal 8 karakter, huruf + angka',
                  textInputAction: .next,
                ),
                const Gap(12),
                FTextField.password(
                  control: .managed(controller: confirmPassword),
                  enabled: !state.isSubmitting,
                  label: const Text('Konfirmasi Password'),
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
                  prefix: state.isSubmitting ? const FCircularProgress() : null,
                  child: Text(state.isSubmitting ? 'Memproses...' : 'Daftar'),
                ),
                const Gap(8),
                FButton(
                  variant: .ghost,
                  onPress: state.isSubmitting
                      ? null
                      : () => context.go(AuthRouter.login.path),
                  child: const Text('Sudah punya akun? Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
