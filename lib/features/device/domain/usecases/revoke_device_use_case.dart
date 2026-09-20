import '../../domain/repositories/device_repository.dart';

class RevokeDeviceUseCase {
  RevokeDeviceUseCase(this._repository);

  final DeviceRepository _repository;

  Future<void> call({required String udid}) =>
      _repository.revokeDevice(udid: udid);
}
