import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/create_translation_help_page.dart';
import 'presentation/pages/my_translation_helps_page.dart';
import 'presentation/pages/translation_help_detail_page.dart';
import 'presentation/pages/translation_help_feed_page.dart';

class TranslationHelpRouter {
  TranslationHelpRouter._();

  static const feed = RouteDefiner(
    path: '/translation-helps',
    name: 'TranslationHelpRouter.feed',
  );

  static const create = RouteDefiner(
    path: '/translation-helps/create',
    name: 'TranslationHelpRouter.create',
  );

  static const mine = RouteDefiner(
    path: '/translation-helps/my',
    name: 'TranslationHelpRouter.mine',
  );

  static const detail = RouteDefiner(
    path: '/translation-helps/:id',
    name: 'TranslationHelpRouter.detail',
  );

  static String detailPath(String id) => '/translation-helps/$id';

  static final List<GoRoute> routes = [
    GoRoute(
      path: feed.path,
      name: feed.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const TranslationHelpFeedPage(),
    ),
    GoRoute(
      path: create.path,
      name: create.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const CreateTranslationHelpPage(),
    ),
    GoRoute(
      path: mine.path,
      name: mine.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const MyTranslationHelpsPage(),
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => TranslationHelpDetailPage(
        id: state.pathParameters['id'] ?? '',
      ),
    ),
  ];
}
