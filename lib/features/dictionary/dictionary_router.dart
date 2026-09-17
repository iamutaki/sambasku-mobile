import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/word_detail_page.dart';

class DictionaryRouter {
  DictionaryRouter._();

  static const detail = RouteDefiner(
    path: '/words/:id',
    name: 'DictionaryRouter.detail',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => WordDetailPage(
        wordId: state.pathParameters['id']!,
      ),
    ),
  ];
}
