// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authTokenStorage)
final authTokenStorageProvider = AuthTokenStorageProvider._();

final class AuthTokenStorageProvider
    extends
        $FunctionalProvider<
          AuthTokenStorage,
          AuthTokenStorage,
          AuthTokenStorage
        >
    with $Provider<AuthTokenStorage> {
  AuthTokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenStorageHash();

  @$internal
  @override
  $ProviderElement<AuthTokenStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthTokenStorage create(Ref ref) {
    return authTokenStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenStorage>(value),
    );
  }
}

String _$authTokenStorageHash() => r'e130a4f875fd7c9d293071d8a77c099ae6cad05b';

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'4b6b8ce6c0eb2fbeb21a74774b81f87315fe5328';
