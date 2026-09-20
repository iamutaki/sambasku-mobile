import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/explore_category_page.dart';

class ExploreRouter {
  ExploreRouter._();

  static const hub = RouteDefiner(
    path: '/explore',
    name: 'ExploreRouter.hub',
  );

  static const category = RouteDefiner(
    path: '/explore/:id',
    name: 'ExploreRouter.category',
  );

  /// Route detail di luar shell (push penuh).
  static final List<GoRoute> routes = [
    GoRoute(
      path: category.path,
      name: category.name,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ExploreCategoryPage(categoryId: id);
      },
    ),
  ];
}
