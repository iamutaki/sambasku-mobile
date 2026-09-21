import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth_router.dart';
import '../providers/auth_status_providers.dart';
import '../providers/auth_verify_providers.dart';

const _resendCooldown = Duration(minutes: 2);

String _formatCooldown(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Input OTP 6 digit, tampilan XXX-XYZ.
class _OtpDashFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 6 ? digits.substring(0, 6) : digits;
    final display = clipped.length <= 3
        ? clipped
        : '${clipped.substring(0, 3)}-${clipped.substring(3)}';
    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }
}

class VerifyEmailPage extends HookConsumerWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
    this.startCooldown = false,
  });

  final String email;
  final bool startCooldown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authVerifyProvider);
    final code = useTextEditingController();
    useListenable(code);
    final remaining = useState(startCooldown ? _resendCooldown.inSeconds : 0);

    useEffect(() {
      if (remaining.value <= 0) return null;
      final timer = Timer(const Duration(seconds: 1), () {
        remaining.value = remaining.value - 1;
      });
      return timer.cancel;
    }, [remaining.value]);

    ref.listen(authStatusProvider, (_, next) {
      if (next.value?.isAuth == true && context.mounted) context.go('/');
    });

    ref.listen(authVerifyProvider.select((s) => s.session), (_, next) {
      if (next != null) context.go('/');
    });

    ref.listen(authVerifyProvider.select((s) => s.resendMessage), (_, next) {
      if (next == null || !context.mounted) return;
      remaining.value = _resendCooldown.inSeconds;
      showFToast(context: context, title: Text(next));
    });

    ref.listen(authVerifyProvider.select((s) => s.errorCode), (_, code) {
      if (code != 'RATE_LIMITED' || !context.mounted) return;
      remaining.value = _resendCooldown.inSeconds;
      showFToast(
        context: context,
        title: Text(
          ref.read(authVerifyProvider).errorMessage ?? 'Coba lagi nanti',
        ),
      );
    });

    final digits = code.text.replaceAll(RegExp(r'\D'), '');
    final canSubmit =
        email.contains('@') && digits.length == 6 && !state.isSubmitting;
    final canResend =
        remaining.value == 0 &&
        !state.isSubmitting &&
        !state.isResending &&
        email.isNotEmpty;
    final theme = context.theme;

    void submit() => ref
        .read(authVerifyProvider.notifier)
        .submit(email: email, code: digits);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Verifikasi email'),
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
                  'Masukkan kode 6 digit',
                  textAlign: .center,
                  style: theme.typography.xl.copyWith(
                    fontWeight: .w600,
                    color: theme.colors.foreground,
                  ),
                ),
                const Gap(8),
                Text(
                  email.isEmpty
                      ? 'Email tidak ada. Kembali ke daftar atau masuk.'
                      : 'Kode dikirim ke $email (berlaku 10 menit). Format XXX-XYZ.',
                  textAlign: .center,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(24),
                FTextField(
                  control: .managed(controller: code),
                  enabled: !state.isSubmitting && email.isNotEmpty,
                  label: const Text('Kode OTP'),
                  hint: '123-456',
                  keyboardType: .number,
                  textInputAction: .done,
                  inputFormatters: [_OtpDashFormatter()],
                  onSubmit: canSubmit ? (_) => submit() : null,
                ),
                if (state.errorMessage != null &&
                    state.errorCode != 'RATE_LIMITED') ...[
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
                  child: Text(
                    state.isSubmitting ? 'Memproses...' : 'Verifikasi',
                  ),
                ),
                const Gap(8),
                FButton(
                  variant: .ghost,
                  onPress: canResend
                      ? () => ref
                            .read(authVerifyProvider.notifier)
                            .resend(email: email)
                      : null,
                  prefix: state.isResending ? const FCircularProgress() : null,
                  child: Text(
                    state.isResending
                        ? 'Mengirim...'
                        : remaining.value > 0
                        ? 'Kirim ulang kode (${_formatCooldown(remaining.value)})'
                        : 'Kirim ulang kode',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
