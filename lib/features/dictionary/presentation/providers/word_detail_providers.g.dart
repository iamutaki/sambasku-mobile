// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).

@ProviderFor(wordDetail)
final wordDetailProvider = WordDetailFamily._();

/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).

final class WordDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<WordDetail>,
          WordDetail,
          FutureOr<WordDetail>
        >
    with $FutureModifier<WordDetail>, $FutureProvider<WordDetail> {
  /// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
  WordDetailProvider._({
    required WordDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wordDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordDetailHash();

  @override
  String toString() {
    return r'wordDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WordDetail> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WordDetail> create(Ref ref) {
    final argument = this.argument as String;
    return wordDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WordDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordDetailHash() => r'dc3e762c88848bf85285729a59f8f0757a9b9e3f';

/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).

final class WordDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WordDetail>, String> {
  WordDetailFamily._()
    : super(
        retry: null,
        name: r'wordDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Load detail kata; error object = [DictionaryFailure] (termasuk 404).

  WordDetailProvider call(String wordId) =>
      WordDetailProvider._(argument: wordId, from: this);

  @override
  String toString() => r'wordDetailProvider';
}
