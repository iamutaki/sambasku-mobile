import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../models/auth_status_state.dart';

part 'auth_status_providers.g.dart';

/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.
@riverpod
class AuthStatusNotifier extends _$AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async {
    final storage = ref.watch(authTokenStorageProvider);
    final isAuth = await storage.getIsAuth();
    final user = await storage.getSessionUser();
    return AuthStatusState(
      isAuth: isAuth,
      username: user.username,
      role: user.role,
    );
  }

  Future<void> logout() async {
    final current = state.value ?? const AuthStatusState();
    state = AsyncData(current.copyWith(isLoggingOut: true));

    await ref.read(authLogoutUseCaseProvider).call();

    state = const AsyncData(AuthStatusState(isAuth: false));
  }
}