import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/my_contributions/my_contributions_router.dart';
import '../../features/notification/notification_router.dart';
import '../router/app_router.dart';

/// Map payload FCM / AwesomeNotifications → rute go_router.
void navigateFromNotificationPayload(Map<String, String?> data) {
  final router = AppRouter.router;
  final type = data['type']?.trim() ?? '';
  final deepLinkKind = data['deep_link_kind']?.trim();
  final deepLinkValue = data['deep_link_value']?.trim();

  // Campaign: deep link opsional, fallback inbox.
  if (type == 'campaign' || data['target_kind']?.trim() == 'campaign') {
    if (deepLinkKind == 'word' && deepLinkValue != null && deepLinkValue.isNotEmpty) {
      _go(router, '/words/$deepLinkValue');
      return;
    }
    if ((deepLinkKind == 'contribution' || deepLinkKind == 'suggestion') &&
        deepLinkValue != null &&
        deepLinkValue.isNotEmpty) {
      _go(
        router,
        MyContributionsRouter.detailPath(
          kind: deepLinkKind!,
          id: deepLinkValue,
        ),
      );
      return;
    }
    // url / none → buka inbox (salinan campaign ada di sana).
    _go(router, NotificationRouter.list.path);
    return;
  }

  final targetKind = data['target_kind']?.trim();
  final targetId =
      data['target_id']?.trim() ??
      data['contribution_id']?.trim() ??
      data['application_id']?.trim();

  if (targetKind == 'word' && targetId != null && targetId.isNotEmpty) {
    _go(router, '/words/$targetId');
    return;
  }

  if (targetKind == 'verifier_application' ||
      type.startsWith('verifier_application')) {
    _go(router, NotificationRouter.list.path);
    return;
  }

  if (targetKind != null &&
      targetKind.isNotEmpty &&
      targetId != null &&
      targetId.isNotEmpty) {
    _go(
      router,
      MyContributionsRouter.detailPath(kind: targetKind, id: targetId),
    );
    return;
  }

  final contributionId = data['contribution_id']?.trim();
  if (contributionId != null && contributionId.isNotEmpty) {
    _go(
      router,
      MyContributionsRouter.detailPath(
        kind: 'contribution',
        id: contributionId,
      ),
    );
    return;
  }

  if (type.isNotEmpty) {
    _go(router, NotificationRouter.list.path);
  }
}

void _go(GoRouter router, String location) {
  try {
    router.push(location);
  } catch (e, st) {
    debugPrint('Notification navigation failed ($location): $e\n$st');
  }
}
