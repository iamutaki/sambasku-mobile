import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/device_registration_holder.dart';
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
      avatarUrl: user.avatarUrl,
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
        avatarUrl: session.avatarUrl,
      ),
    );
    // Sama seperti logout: list keepAlive watch authStatus, cukup rebuild.
  }

  /// Update avatar setelah upload/hapus tanpa reload storage penuh.
  Future<void> setAvatarUrl(String? avatarUrl) async {
    final current = state.value ?? const AuthStatusState();
    final storage = ref.read(authTokenStorageProvider);
    final user = await storage.getSessionUser();
    final next = (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : null;
    if (user.username != null && user.username!.isNotEmpty) {
      await storage.saveSessionUser(
        username: user.username!,
        role: user.role,
        userId: user.userId,
        avatarUrl: next,
      );
    }
    state = AsyncData(
      current.copyWith(clearAvatarUrl: true).copyWith(avatarUrl: next),
    );
  }

  Future<void> logout() async {
    final current = state.value ?? const AuthStatusState();
    state = AsyncData(current.copyWith(isLoggingOut: true));

    // Detach FCM dulu (butuh access token masih valid). Jika access sudah
    // expired, PATCH /device/revoke dapat 401 - AuthInterceptor skip refresh
    // untuk path itu supaya tidak infinite loop.
    await DeviceRegistrationHolder.instance?.revokeBestEffort();

    await ref.read(authLogoutUseCaseProvider).call();

    state = const AsyncData(AuthStatusState(isAuth: false));
    AnalyticsService.instance.log(AnalyticsEvents.authLogout);
    // Jangan invalidate bookmark/kontribusi/notifikasi: mereka sudah
    // `watch` authStatus. Invalidate saat rebuild → circular Riverpod 3.
  }
}
