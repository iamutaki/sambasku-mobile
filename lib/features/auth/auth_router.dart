import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';

class AuthRouter {
  AuthRouter._();

  static const login = RouteDefiner(path: '/login', name: 'AuthRouter.login');
  static const register =
      RouteDefiner(path: '/register', name: 'AuthRouter.register');

  static final List<GoRoute> routes = [
    GoRoute(
      path: login.path,
      name: login.name,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: register.path,
      name: register.name,
      builder: (context, state) => const RegisterPage(),
    ),
  ];
}
