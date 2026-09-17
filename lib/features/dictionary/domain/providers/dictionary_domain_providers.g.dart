// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchWordsUseCase)
final searchWordsUseCaseProvider = SearchWordsUseCaseProvider._();

final class SearchWordsUseCaseProvider
    extends
        $FunctionalProvider<
          SearchWordsUseCase,
          SearchWordsUseCase,
          SearchWordsUseCase
        >
    with $Provider<SearchWordsUseCase> {
  SearchWordsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchWordsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchWordsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SearchWordsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchWordsUseCase create(Ref ref) {
    return searchWordsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchWordsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchWordsUseCase>(value),
    );
  }
}

String _$searchWordsUseCaseHash() =>
    r'c9a95b5314fc2b144ac122a9df2c06e3dca937a7';

@ProviderFor(getWordByIdUseCase)
final getWordByIdUseCaseProvider = GetWordByIdUseCaseProvider._();

final class GetWordByIdUseCaseProvider
    extends
        $FunctionalProvider<
          GetWordByIdUseCase,
          GetWordByIdUseCase,
          GetWordByIdUseCase
        >
    with $Provider<GetWordByIdUseCase> {
  GetWordByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getWordByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getWordByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetWordByIdUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetWordByIdUseCase create(Ref ref) {
    return getWordByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWordByIdUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWordByIdUseCase>(value),
    );
  }
}

String _$getWordByIdUseCaseHash() =>
    r'406ea3691c39a1305a828ed2f6e116c690bc4e66';
