import 'package:dio/dio.dart';

import '../../services/rate_limit_device_id.dart';

/// Sisipkan X-Device-Id di setiap request API (rate limit anonim dual-bucket).
class DeviceIdInterceptor extends Interceptor {
  DeviceIdInterceptor(this._ids);

  final RateLimitDeviceIdService _ids;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      options.headers['X-Device-Id'] = await _ids.getId();
    } catch (_) {}
    handler.next(options);
  }
}
