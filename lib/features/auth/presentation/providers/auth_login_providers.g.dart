// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthLoginNotifier)
final authLoginProvider = AuthLoginNotifierProvider._();

final class AuthLoginNotifierProvider
    extends $NotifierProvider<AuthLoginNotifier, AuthLoginState> {
  AuthLoginNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoginProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoginNotifierHash();

  @$internal
  @override
  AuthLoginNotifier create() => AuthLoginNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLoginState>(value),
    );
  }
}

String _$authLoginNotifierHash() => r'd4a8082ab351392d0f3a96afa3a6cb71441982c4';

abstract class _$AuthLoginNotifier extends $Notifier<AuthLoginState> {
  AuthLoginState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthLoginState, AuthLoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthLoginState, AuthLoginState>,
              AuthLoginState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
