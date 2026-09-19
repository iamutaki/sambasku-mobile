// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_status_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.

@ProviderFor(AuthStatusNotifier)
final authStatusProvider = AuthStatusNotifierProvider._();

/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.
final class AuthStatusNotifierProvider
    extends $AsyncNotifierProvider<AuthStatusNotifier, AuthStatusState> {
  /// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
  /// supaya Profile + router otomatis tahu user sudah jadi tamu.
  AuthStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusNotifierHash();

  @$internal
  @override
  AuthStatusNotifier create() => AuthStatusNotifier();
}

String _$authStatusNotifierHash() =>
    r'9bf198980e7083524c2f3a1ab222cdd72fe1fe1b';

/// Status auth global (reaktif) dari AuthTokenStorage. Logout lewat sini
/// supaya Profile + router otomatis tahu user sudah jadi tamu.

abstract class _$AuthStatusNotifier extends $AsyncNotifier<AuthStatusState> {
  FutureOr<AuthStatusState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthStatusState>, AuthStatusState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthStatusState>, AuthStatusState>,
              AsyncValue<AuthStatusState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
