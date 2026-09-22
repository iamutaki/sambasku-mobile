import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/my_comments_page.dart';

class MyCommentsRouter {
  MyCommentsRouter._();

  static const list = RouteDefiner(
    path: '/comments',
    name: 'MyCommentsRouter.list',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const MyCommentsPage(),
    ),
  ];
}
