import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/dev_tool/network_monitor/network_monitor_registry.dart';
import '../constants/env.dart';
import 'auth_token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/network_monitor_interceptor.dart';

part 'network_providers.g.dart';

@riverpod
AuthTokenStorage authTokenStorage(Ref ref) => AuthTokenStorage.instance;

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiHost,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  // network monitor dulu supaya AuthInterceptor refresh juga terekam
  dio.interceptors.add(
    NetworkMonitorInterceptor(
      repository: NetworkMonitorRegistry.repository,
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: ref.watch(authTokenStorageProvider),
      baseUrl: Env.apiHost,
    ),
  );
  return dio;
}
