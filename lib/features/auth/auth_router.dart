import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/login_page.dart';

class AuthRouter {
  AuthRouter._();

  static const login = RouteDefiner(path: '/login', name: 'AuthRouter.login');

  static final List<GoRoute> routes = [
    GoRoute(
      path: login.path,
      name: login.name,
      builder: (context, state) => const LoginPage(),
    ),
  ];
}
