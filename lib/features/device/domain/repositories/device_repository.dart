abstract interface class DeviceRepository {
  Future<void> registerDevice({
    required String udid,
    required String fcmToken,
  });

  Future<void> revokeDevice({required String udid});
}
