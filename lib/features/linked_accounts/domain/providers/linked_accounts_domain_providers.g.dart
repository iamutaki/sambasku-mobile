// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_accounts_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getGoogleLinkStatusUseCase)
final getGoogleLinkStatusUseCaseProvider =
    GetGoogleLinkStatusUseCaseProvider._();

final class GetGoogleLinkStatusUseCaseProvider
    extends
        $FunctionalProvider<
          GetGoogleLinkStatusUseCase,
          GetGoogleLinkStatusUseCase,
          GetGoogleLinkStatusUseCase
        >
    with $Provider<GetGoogleLinkStatusUseCase> {
  GetGoogleLinkStatusUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getGoogleLinkStatusUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getGoogleLinkStatusUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetGoogleLinkStatusUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetGoogleLinkStatusUseCase create(Ref ref) {
    return getGoogleLinkStatusUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetGoogleLinkStatusUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetGoogleLinkStatusUseCase>(value),
    );
  }
}

String _$getGoogleLinkStatusUseCaseHash() =>
    r'0eccc12e4f7528333ca4bd4b7e4094e3a53355a2';

@ProviderFor(linkGoogleAccountUseCase)
final linkGoogleAccountUseCaseProvider = LinkGoogleAccountUseCaseProvider._();

final class LinkGoogleAccountUseCaseProvider
    extends
        $FunctionalProvider<
          LinkGoogleAccountUseCase,
          LinkGoogleAccountUseCase,
          LinkGoogleAccountUseCase
        >
    with $Provider<LinkGoogleAccountUseCase> {
  LinkGoogleAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkGoogleAccountUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkGoogleAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<LinkGoogleAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinkGoogleAccountUseCase create(Ref ref) {
    return linkGoogleAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkGoogleAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkGoogleAccountUseCase>(value),
    );
  }
}

String _$linkGoogleAccountUseCaseHash() =>
    r'e9e6fc172970457b1dbdf8900370fe393ee67dcb';

@ProviderFor(unlinkGoogleAccountUseCase)
final unlinkGoogleAccountUseCaseProvider =
    UnlinkGoogleAccountUseCaseProvider._();

final class UnlinkGoogleAccountUseCaseProvider
    extends
        $FunctionalProvider<
          UnlinkGoogleAccountUseCase,
          UnlinkGoogleAccountUseCase,
          UnlinkGoogleAccountUseCase
        >
    with $Provider<UnlinkGoogleAccountUseCase> {
  UnlinkGoogleAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlinkGoogleAccountUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlinkGoogleAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<UnlinkGoogleAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnlinkGoogleAccountUseCase create(Ref ref) {
    return unlinkGoogleAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnlinkGoogleAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnlinkGoogleAccountUseCase>(value),
    );
  }
}

String _$unlinkGoogleAccountUseCaseHash() =>
    r'92c04a71d4cf73aefd05dbc2c280d6bb962d53be';
