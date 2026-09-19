import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/change_password_page.dart';

class ChangePasswordRouter {
  ChangePasswordRouter._();

  static const changePassword = RouteDefiner(
    path: '/change-password',
    name: 'ChangePasswordRouter.changePassword',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: changePassword.path,
      name: changePassword.name,
      builder: (context, state) => const ChangePasswordPage(),
    ),
  ];
}
