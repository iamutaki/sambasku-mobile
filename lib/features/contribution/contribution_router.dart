import 'package:go_router/go_router.dart';

import 'presentation/pages/contribute_page.dart';

/// Router form usul kata baru (`/contribute`). Daftar + detail status
/// milik user ada di `MyContributionsRouter` (`/contributions`).
class ContributionRouter {
  ContributionRouter._();

  static const contribute = GoRouteData._(
    path: '/contribute',
    name: 'ContributionRouter.contribute',
  );

  static List<RouteBase> get routes => [
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) {
        final q = state.uri.queryParameters;
        final lemma = q['lemma'];
        final searchIn = q['search_in'];
        final missId = q['miss_id'] ?? q['search_miss_id'];
        return ContributePage(
          initialLemma: lemma,
          initialSearchIn: searchIn,
          initialSearchMissId: missId,
        );
      },
    ),
  ];
}

class GoRouteData {
  const GoRouteData._({required this.path, required this.name});
  final String path;
  final String name;
}
