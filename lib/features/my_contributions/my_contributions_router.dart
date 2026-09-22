import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/my_contribution_detail_page.dart';
import 'presentation/pages/my_contributions_page.dart';

class MyContributionsRouter {
  MyContributionsRouter._();

  static const list = RouteDefiner(
    path: '/contributions',
    name: 'MyContributionsRouter.list',
  );

  static const detail = RouteDefiner(
    path: '/contributions/:kind/:id',
    name: 'MyContributionsRouter.detail',
  );

  static String detailPath({required String kind, required String id}) =>
      '/contributions/$kind/$id';

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const MyContributionsPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => MyContributionDetailPage(
        kind: state.pathParameters['kind'] ?? '',
        id: state.pathParameters['id'] ?? '',
      ),
    ),
  ];
}
