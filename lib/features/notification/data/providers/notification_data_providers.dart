import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/notification_repository.dart';
import '../repositories/notification_repository_impl.dart';

part 'notification_data_providers.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepositoryImpl(ref.watch(dioProvider));
