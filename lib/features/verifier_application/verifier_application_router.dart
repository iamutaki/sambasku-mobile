import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/verifier_application_page.dart';

class VerifierApplicationRouter {
  VerifierApplicationRouter._();

  static const apply = RouteDefiner(
    path: '/verifier-application',
    name: 'VerifierApplicationRouter.apply',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: apply.path,
      name: apply.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const VerifierApplicationPage(),
    ),
  ];
}
