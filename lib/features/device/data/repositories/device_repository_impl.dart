import 'package:dio/dio.dart';

import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/register_device_request_dto.dart';
import '../models/revoke_device_request_dto.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._remote);

  final DeviceRemoteDatasource _remote;

  @override
  Future<void> registerDevice({
    required String udid,
    required String fcmToken,
  }) async {
    try {
      await _remote.registerDevice(
        RegisterDeviceRequestDto(udid: udid, fcmToken: fcmToken),
      );
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> revokeDevice({required String udid}) async {
    try {
      await _remote.revokeDevice(RevokeDeviceRequestDto(udid: udid));
    } on DioException {
      rethrow;
    }
  }
}
