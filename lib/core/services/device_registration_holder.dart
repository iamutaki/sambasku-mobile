import 'device_registration_service.dart';

/// Holder singleton agar logout / AuthInterceptor bisa revoke FCM tanpa
/// circular Riverpod dependency di bootstrap.
class DeviceRegistrationHolder {
  DeviceRegistrationHolder._();

  static DeviceRegistrationService? instance;
}
