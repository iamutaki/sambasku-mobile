// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DictionarySearchNotifier)
final dictionarySearchProvider = DictionarySearchNotifierProvider._();

final class DictionarySearchNotifierProvider
    extends $NotifierProvider<DictionarySearchNotifier, DictionarySearchState> {
  DictionarySearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionarySearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionarySearchNotifierHash();

  @$internal
  @override
  DictionarySearchNotifier create() => DictionarySearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DictionarySearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DictionarySearchState>(value),
    );
  }
}

String _$dictionarySearchNotifierHash() =>
    r'3d0369612eaef082f315c413217e723419cb1da6';

abstract class _$DictionarySearchNotifier
    extends $Notifier<DictionarySearchState> {
  DictionarySearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DictionarySearchState, DictionarySearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DictionarySearchState, DictionarySearchState>,
              DictionarySearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
