import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../bookmark/presentation/providers/bookmark_providers.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../models/auth_status_state.dart';

part 'auth_status_providers.g.dart';

/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.
///
/// keepAlive: sesi tidak boleh autoDispose saat pindah /login → / (gap
/// antar listener sempat cancel rebuild + sisakan cache isAuth:false).
@Riverpod(keepAlive: true)
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
      userId: user.userId,
    );
  }

  /// Dipanggil langsung setelah login sukses (token sudah di storage).
  /// Hindari invalidate auth: reload async masih bawa previous isAuth:false
  /// → form KBBI/gambar sempat mengira user masih tamu.
  void markLoggedIn(AuthSession session) {
    state = AsyncData(
      AuthStatusState(
        isAuth: true,
        username: session.username,
        role: session.role,
        userId: session.userId,
      ),
    );
    _invalidateBookmarks();
  }

  Future<void> logout() async {
    final current = state.value ?? const AuthStatusState();
    state = AsyncData(current.copyWith(isLoggingOut: true));

    await ref.read(authLogoutUseCaseProvider).call();

    state = const AsyncData(AuthStatusState(isAuth: false));
    _invalidateBookmarks();
  }

  /// Bookmark terikat user: list keepAlive + toggle per-kata harus
  /// di-reset saat sesi berganti (login user lain / logout).
  void _invalidateBookmarks() {
    ref.invalidate(bookmarkListControllerProvider);
    ref.invalidate(bookmarkToggleControllerProvider);
  }
}