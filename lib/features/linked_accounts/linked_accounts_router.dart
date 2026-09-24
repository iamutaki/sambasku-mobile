import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/linked_accounts_page.dart';

class LinkedAccountsRouter {
  LinkedAccountsRouter._();

  static const linkedAccounts = RouteDefiner(
    path: '/linked-accounts',
    name: 'LinkedAccountsRouter.linkedAccounts',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: linkedAccounts.path,
      name: linkedAccounts.name,
      builder: (context, state) => const LinkedAccountsPage(),
    ),
  ];
}
