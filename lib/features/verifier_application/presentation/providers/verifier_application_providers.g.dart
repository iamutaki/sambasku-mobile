// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifier_application_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VerifierApplicationNotifier)
final verifierApplicationProvider = VerifierApplicationNotifierProvider._();

final class VerifierApplicationNotifierProvider
    extends
        $NotifierProvider<
          VerifierApplicationNotifier,
          VerifierApplicationState
        > {
  VerifierApplicationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifierApplicationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifierApplicationNotifierHash();

  @$internal
  @override
  VerifierApplicationNotifier create() => VerifierApplicationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifierApplicationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifierApplicationState>(value),
    );
  }
}

String _$verifierApplicationNotifierHash() =>
    r'd6fdf0f40cb875e2f00612c8df7295af537acdf6';

abstract class _$VerifierApplicationNotifier
    extends $Notifier<VerifierApplicationState> {
  VerifierApplicationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<VerifierApplicationState, VerifierApplicationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerifierApplicationState, VerifierApplicationState>,
              VerifierApplicationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
