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

String _$authLoginNotifierHash() => r'd5055ea2e0a0507c958993784127039e13cfab96';

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
