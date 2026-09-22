// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per `wordId` tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch.
/// Pull-to-refresh di halaman detail memanggil `invalidate` + await
/// `.future` supaya data segar.

@ProviderFor(wordDetail)
final wordDetailProvider = WordDetailFamily._();

/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per `wordId` tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch.
/// Pull-to-refresh di halaman detail memanggil `invalidate` + await
/// `.future` supaya data segar.

final class WordDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<WordDetail>,
          WordDetail,
          FutureOr<WordDetail>
        >
    with $FutureModifier<WordDetail>, $FutureProvider<WordDetail> {
  /// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
  ///
  /// keepAlive: family per `wordId` tetap di cache saat pop detail → buka
  /// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch.
  /// Pull-to-refresh di halaman detail memanggil `invalidate` + await
  /// `.future` supaya data segar.
  WordDetailProvider._({
    required WordDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wordDetailProvider',
         isAutoDispose: false,
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

String _$wordDetailHash() => r'49559f87b2469f1584d0b6bae9a5cd6f52746bfe';

/// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
///
/// keepAlive: family per `wordId` tetap di cache saat pop detail → buka
/// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch.
/// Pull-to-refresh di halaman detail memanggil `invalidate` + await
/// `.future` supaya data segar.

final class WordDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WordDetail>, String> {
  WordDetailFamily._()
    : super(
        retry: null,
        name: r'wordDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Load detail kata; error object = [DictionaryFailure] (termasuk 404).
  ///
  /// keepAlive: family per `wordId` tetap di cache saat pop detail → buka
  /// lagi / navigasi antar kata yang sudah pernah dibuka tidak refetch.
  /// Pull-to-refresh di halaman detail memanggil `invalidate` + await
  /// `.future` supaya data segar.

  WordDetailProvider call(String wordId) =>
      WordDetailProvider._(argument: wordId, from: this);

  @override
  String toString() => r'wordDetailProvider';
}
