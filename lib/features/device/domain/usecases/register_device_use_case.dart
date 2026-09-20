import '../../domain/repositories/device_repository.dart';

class RegisterDeviceUseCase {
  RegisterDeviceUseCase(this._repository);

  final DeviceRepository _repository;

  Future<void> call({
    required String udid,
    required String fcmToken,
  }) =>
      _repository.registerDevice(udid: udid, fcmToken: fcmToken);
}
