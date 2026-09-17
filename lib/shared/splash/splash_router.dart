import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/splash_page.dart';

class SplashRouter {
  SplashRouter._();

  static const splash =
      RouteDefiner(path: '/splash', name: 'SplashRouter.splash');

  static final List<GoRoute> routes = [
    GoRoute(
      path: splash.path,
      name: splash.name,
      builder: (context, state) => const SplashPage(),
    ),
  ];
}
