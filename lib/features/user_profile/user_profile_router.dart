import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/public_profile_page.dart';

class UserProfileRouter {
  UserProfileRouter._();

  static const profile = RouteDefiner(
    path: '/users/:username',
    name: 'UserProfileRouter.profile',
  );

  static void open(BuildContext context, String username) {
    context.push('/users/${Uri.encodeComponent(username)}');
  }

  static final List<GoRoute> routes = [
    GoRoute(
      path: profile.path,
      name: profile.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) =>
          PublicProfilePage(username: state.pathParameters['username'] ?? ''),
    ),
  ];
}
