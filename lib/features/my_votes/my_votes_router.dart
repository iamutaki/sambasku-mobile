import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/my_votes_page.dart';

class MyVotesRouter {
  MyVotesRouter._();

  static const list = RouteDefiner(
    path: '/votes',
    name: 'MyVotesRouter.list',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const MyVotesPage(),
    ),
  ];
}
