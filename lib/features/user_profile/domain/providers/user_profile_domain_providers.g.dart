// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getPublicProfileUseCase)
final getPublicProfileUseCaseProvider = GetPublicProfileUseCaseProvider._();

final class GetPublicProfileUseCaseProvider
    extends
        $FunctionalProvider<
          GetPublicProfileUseCase,
          GetPublicProfileUseCase,
          GetPublicProfileUseCase
        >
    with $Provider<GetPublicProfileUseCase> {
  GetPublicProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPublicProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPublicProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPublicProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPublicProfileUseCase create(Ref ref) {
    return getPublicProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPublicProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPublicProfileUseCase>(value),
    );
  }
}

String _$getPublicProfileUseCaseHash() =>
    r'8d1e04cd81ef77795681dc2c7018aee76ad9dcf7';
