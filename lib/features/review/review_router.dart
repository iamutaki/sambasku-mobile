import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/review_queue_page.dart';
import 'presentation/pages/review_session_page.dart';
import 'presentation/widgets/review_gate.dart';

class ReviewRouter {
  ReviewRouter._();

  static const list = RouteDefiner(path: '/review', name: 'ReviewRouter.list');
  static const session = RouteDefiner(
    path: '/review/session',
    name: 'ReviewRouter.session',
  );
  static const detail = RouteDefiner(
    path: '/review/:id',
    name: 'ReviewRouter.detail',
  );
  static const correct = RouteDefiner(
    path: '/review/:id/correct',
    name: 'ReviewRouter.correct',
  );

  static String detailPath(String id) => sessionPath(startId: id);

  static String sessionPath({
    String? startId,
    String? wordId,
    bool openCorrect = false,
  }) {
    final params = <String, String>{};
    if (startId != null && startId.isNotEmpty) {
      params['startId'] = startId;
    }
    if (wordId != null && wordId.isNotEmpty) {
      params['wordId'] = wordId;
    }
    if (openCorrect) {
      params['mode'] = 'correct';
    }
    if (params.isEmpty) return session.path;
    final query = params.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
    return '${session.path}?$query';
  }

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => ReviewGate(
        child: ReviewQueuePage(wordId: state.uri.queryParameters['wordId']),
      ),
    ),
    // Harus sebelum /review/:id supaya "session" tidak tertangkap sebagai id.
    GoRoute(
      path: session.path,
      name: session.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return ReviewGate(
          child: ReviewSessionPage(
            startId: params['startId'],
            wordId: params['wordId'],
            openCorrect: params['mode'] == 'correct',
          ),
        );
      },
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      redirect: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        if (id.isEmpty || id == 'session') return list.path;
        return sessionPath(
          startId: id,
          wordId: state.uri.queryParameters['wordId'],
        );
      },
    ),
    GoRoute(
      path: correct.path,
      name: correct.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      redirect: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        if (id.isEmpty) return list.path;
        return sessionPath(
          startId: id,
          wordId: state.uri.queryParameters['wordId'],
          openCorrect: true,
        );
      },
    ),
  ];
}
