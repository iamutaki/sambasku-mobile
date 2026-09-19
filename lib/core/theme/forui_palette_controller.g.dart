// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forui_palette_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Palet warna forui pilihan user: default zinc, persist ke SharedPreferences.

@ProviderFor(ForuiPaletteController)
final foruiPaletteControllerProvider = ForuiPaletteControllerProvider._();

/// Palet warna forui pilihan user: default zinc, persist ke SharedPreferences.
final class ForuiPaletteControllerProvider
    extends $NotifierProvider<ForuiPaletteController, String> {
  /// Palet warna forui pilihan user: default zinc, persist ke SharedPreferences.
  ForuiPaletteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foruiPaletteControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foruiPaletteControllerHash();

  @$internal
  @override
  ForuiPaletteController create() => ForuiPaletteController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$foruiPaletteControllerHash() =>
    r'1df45c1b7d1e937c67c743f6af926a6a500c854b';

/// Palet warna forui pilihan user: default zinc, persist ke SharedPreferences.

abstract class _$ForuiPaletteController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
