import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/about_router.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/auth/auth_router.dart';
import '../../features/bookmark/bookmark_router.dart';
import '../../features/change_password/change_password_router.dart';
import '../../features/contribution/contribution_router.dart';
import '../../features/dictionary/dictionary_router.dart';
import '../../features/dictionary/presentation/pages/home_search_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/splash/splash_router.dart';
import '../network/auth_token_storage.dart';

/// Router utama (pola jnn_mobile):
/// - redirect auth global (isAuth dari AuthTokenStorage)
/// - StatefulShellRoute = 3 tab bottom nav: Home (pencarian), Action
///   (kontribusi - placeholder), Profile (placeholder)
/// - cold start langsung HOME (pencarian publik tanpa login)
class AppRouter {
  AppRouter._();

  /// Root navigator key - dipakai DevToolOverlay untuk push di atas GoRouter.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final AuthTokenStorage _tokenStorage = AuthTokenStorage.instance;

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ...SplashRouter.routes,
      ...AuthRouter.routes,
      ...ChangePasswordRouter.routes,
      ...AboutRouter.routes,
      ...DictionaryRouter.routes,
      ...ContributionRouter.routes,
      ...BookmarkRouter.routes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              name: 'HomeRouter.search',
              builder: (context, state) => const HomeSearchPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/action',
              name: 'ActionRouter.activity',
              builder: (context, state) => const ActivityPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              name: 'ProfileRouter.profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
    ],
    redirect: _redirect,
    errorBuilder: (context, state) => FScaffold(
      childPad: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Halaman tidak ditemukan: ${state.error}'),
        ),
      ),
    ),
  );

  /// Tamu BOLEH pakai app (pencarian publik). Redirect hanya:
  /// - user sudah login tapi masih di /login atau /register → HOME
  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isAuth = await _tokenStorage.getIsAuth();
    final loc = state.matchedLocation;
    final isOnAuth =
        loc == AuthRouter.login.path || loc == AuthRouter.register.path;

    if (isAuth && isOnAuth) return '/';

    return null;
  }
}

/// Shell 3 tab bottom navigation (Forui).
class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // resizeToAvoidBottomInset false: keyboard tidak dorong bottom nav
    // (nested scaffold + inset = overflow / "geser drawer")
    // footerDecoration dikosongkan - FBottomNavigationBar sudah punya top border
    return FScaffold(
      childPad: true,
      resizeToAvoidBottomInset: false,
      scaffoldStyle: .delta(footerDecoration: .value(const BoxDecoration())),
      footer: FBottomNavigationBar(
        index: navigationShell.currentIndex,
        onChange: (index) {
          // IndexedStack menyimpan fokus search → keyboard ikut "nempel"
          // saat ganti tab / setelah hot reload. Unfocus dulu.
          FocusManager.instance.primaryFocus?.unfocus();
          navigationShell.goBranch(index);
        },
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(FLucideIcons.house),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FLucideIcons.circlePlus),
            label: Text('Kontribusi'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FLucideIcons.userRound),
            label: Text('Profil'),
          ),
        ],
      ),
      child: navigationShell,
    );
  }
}
