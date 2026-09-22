import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/onboarding_page.dart';

class OnboardingRouter {
  OnboardingRouter._();

  static const onboarding = RouteDefiner(
    path: '/onboarding',
    name: 'OnboardingRouter.onboarding',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: onboarding.path,
      name: onboarding.name,
      builder: (context, state) => const OnboardingPage(),
    ),
  ];
}
