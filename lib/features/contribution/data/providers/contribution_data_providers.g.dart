// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contributionRemoteDatasource)
final contributionRemoteDatasourceProvider =
    ContributionRemoteDatasourceProvider._();

final class ContributionRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          ContributionRemoteDatasource,
          ContributionRemoteDatasource,
          ContributionRemoteDatasource
        >
    with $Provider<ContributionRemoteDatasource> {
  ContributionRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributionRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributionRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<ContributionRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContributionRemoteDatasource create(Ref ref) {
    return contributionRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContributionRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContributionRemoteDatasource>(value),
    );
  }
}

String _$contributionRemoteDatasourceHash() =>
    r'7904ab84083bb0f057459fd1732bf8e1100e5b37';

@ProviderFor(contributionRepository)
final contributionRepositoryProvider = ContributionRepositoryProvider._();

final class ContributionRepositoryProvider
    extends
        $FunctionalProvider<
          ContributionRepository,
          ContributionRepository,
          ContributionRepository
        >
    with $Provider<ContributionRepository> {
  ContributionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributionRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContributionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContributionRepository create(Ref ref) {
    return contributionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContributionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContributionRepository>(value),
    );
  }
}

String _$contributionRepositoryHash() =>
    r'ef12b6ec97eb9ca82c2e2a9196cb31dcac4c37f5';
