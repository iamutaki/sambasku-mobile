import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'device_registration_holder.dart';

/// Foreground FCM → Awesome Notifications (in-app saat app dibuka).
/// Permission diminta dari onboarding slide 3, bukan di cold start.
class NotificationService {
  NotificationService._();

  static const _channelKey = 'sambasku_notifications';

  /// Init channel + listener tanpa meminta izin OS.
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'SambasKu',
          channelDescription: 'Notifikasi dari SambasKu',
          defaultColor: const Color(0xFF0F766E),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
      ],
      debug: kDebugMode,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
    );

    debugPrint('NotificationService initialized (awesome_notifications)');
  }

  /// Dipanggil dari onboarding slide 3 saat user tap Izinkan.
  static Future<void> requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission();
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    await DeviceRegistrationHolder.instance?.refreshFcmTokenAndRegister();
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String?;
    final body = notification?.body ?? message.data['body'] as String?;
    if (title == null && body == null) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode.abs() % 100000,
        channelKey: _channelKey,
        title: title ?? 'SambasKu',
        body: body ?? '',
        payload: message.data.map((k, v) => MapEntry(k, v.toString())),
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {
    debugPrint('Notification tapped: ${action.payload}');
    // TODO: navigasi berdasarkan payload (contribution_id, dll.)
  }
}
