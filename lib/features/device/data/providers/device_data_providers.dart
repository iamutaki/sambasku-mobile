import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';
import '../repositories/device_repository_impl.dart';

part 'device_data_providers.g.dart';

@riverpod
DeviceRemoteDatasource deviceRemoteDatasource(Ref ref) =>
    DeviceRemoteDatasource(ref.watch(dioProvider));

@riverpod
DeviceRepository deviceRepository(Ref ref) =>
    DeviceRepositoryImpl(ref.watch(deviceRemoteDatasourceProvider));
