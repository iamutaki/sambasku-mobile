import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/search_miss_list_page.dart';

class SearchMissRouter {
  SearchMissRouter._();

  static const list = RouteDefiner(
    path: '/search-misses',
    name: 'SearchMissRouter.list',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const SearchMissListPage(),
    ),
  ];
}
