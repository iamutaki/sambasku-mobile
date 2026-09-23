import 'package:flutter/widgets.dart';

import 'analytics_service.dart';

/// Observer GoRouter → `screen_view` (Section 14 mobile-base-stack).
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver({AnalyticsService? analytics})
      : _analytics = analytics ?? AnalyticsService.instance;

  final AnalyticsService _analytics;

  void _log(Route<dynamic>? route) {
    if (route is! PageRoute) return;
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    _analytics.logScreenView(name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log(newRoute);
  }
}

/// Hook GoRouter: panggil dari `GoRouter(observers: [...])`.
List<NavigatorObserver> analyticsNavigatorObservers() => [
      AnalyticsRouteObserver(),
    ];
