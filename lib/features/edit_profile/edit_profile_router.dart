import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/edit_profile_page.dart';

class EditProfileRouter {
  EditProfileRouter._();

  static const editProfile = RouteDefiner(
    path: '/edit-profile',
    name: 'EditProfileRouter.editProfile',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: editProfile.path,
      name: editProfile.name,
      builder: (context, state) => const EditProfilePage(),
    ),
  ];
}
