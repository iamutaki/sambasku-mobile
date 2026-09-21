import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/notification_inbox_page.dart';

class NotificationRouter {
  NotificationRouter._();

  static const list = RouteDefiner(
    path: '/notifications',
    name: 'NotificationRouter.list',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const NotificationInboxPage(),
    ),
  ];
}
