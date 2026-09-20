import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../usecases/register_device_use_case.dart';
import '../usecases/revoke_device_use_case.dart';
import '../../data/providers/device_data_providers.dart';

part 'device_domain_providers.g.dart';

@riverpod
RegisterDeviceUseCase registerDeviceUseCase(Ref ref) =>
    RegisterDeviceUseCase(ref.watch(deviceRepositoryProvider));

@riverpod
RevokeDeviceUseCase revokeDeviceUseCase(Ref ref) =>
    RevokeDeviceUseCase(ref.watch(deviceRepositoryProvider));
