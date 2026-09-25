import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/delete_account_page.dart';

class DeleteAccountRouter {
  DeleteAccountRouter._();

  static const deleteAccount = RouteDefiner(
    path: '/delete-account',
    name: 'DeleteAccountRouter.deleteAccount',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: deleteAccount.path,
      name: deleteAccount.name,
      builder: (context, state) => const DeleteAccountPage(),
    ),
  ];
}
