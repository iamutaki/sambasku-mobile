import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/bookmark_page.dart';

class BookmarkRouter {
  BookmarkRouter._();

  static const list = RouteDefiner(
    path: '/bookmarks',
    name: 'BookmarkRouter.list',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const BookmarkPage(),
    ),
  ];
}
