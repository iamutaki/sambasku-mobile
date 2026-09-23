import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/review_correct_page.dart';
import 'presentation/pages/review_detail_page.dart';
import 'presentation/pages/review_queue_page.dart';
import 'presentation/widgets/review_gate.dart';

class ReviewRouter {
  ReviewRouter._();

  static const list = RouteDefiner(path: '/review', name: 'ReviewRouter.list');
  static const detail = RouteDefiner(
    path: '/review/:id',
    name: 'ReviewRouter.detail',
  );
  static const correct = RouteDefiner(
    path: '/review/:id/correct',
    name: 'ReviewRouter.correct',
  );

  static String detailPath(String id) => '/review/$id';

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => ReviewGate(
        child: ReviewQueuePage(wordId: state.uri.queryParameters['wordId']),
      ),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => ReviewGate(
        child: ReviewDetailPage(id: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: correct.path,
      name: correct.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => ReviewGate(
        child: ReviewCorrectPage(id: state.pathParameters['id'] ?? ''),
      ),
    ),
  ];
}
