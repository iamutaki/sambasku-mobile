import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/notification_data_providers.dart';
import '../usecases/notification_use_cases.dart';

part 'notification_domain_providers.g.dart';

@riverpod
ListMyNotificationsUseCase listMyNotificationsUseCase(Ref ref) =>
    ListMyNotificationsUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
GetUnreadNotificationCountUseCase getUnreadNotificationCountUseCase(Ref ref) =>
    GetUnreadNotificationCountUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
MarkNotificationReadUseCase markNotificationReadUseCase(Ref ref) =>
    MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider));

@riverpod
MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase(Ref ref) =>
    MarkAllNotificationsReadUseCase(ref.watch(notificationRepositoryProvider));
