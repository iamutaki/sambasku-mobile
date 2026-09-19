import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/failures/contribution_failure.dart';
import '../models/submit_word_state.dart';
import '../providers/submit_word_providers.dart';
import '../widgets/contribute_images_field.dart';
import '../widgets/kbbi_definition_sheet.dart';
import '../widgets/word_class_picker_sheet.dart';

class ContributePage extends ConsumerStatefulWidget {
  const ContributePage({
    super.key,
    this.initialLemma,
    this.initialSearchIn,
    this.initialSearchMissId,
  });

  final String? initialLemma;
  final String? initialSearchIn;
  final String? initialSearchMissId;

  @override
  ConsumerState<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends ConsumerState<ContributePage> {
  late final TextEditingController _lemmaCtrl;
  late final TextEditingController _defCtrl;
  late final TextEditingController _tr1Ctrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _variantsCtrl;

  String? _wordClassId;
  String? _dialectId;
  List<ContributeImageSlot> _images = const [];

  @override
  void initState() {
    super.initState();
    final isTranslationMiss = widget.initialSearchIn == 'translation';
    _lemmaCtrl = TextEditingController(
      text: isTranslationMiss ? '' : (widget.initialLemma ?? ''),
    );
    _defCtrl = TextEditingController();
    _tr1Ctrl = TextEditingController(
      text: isTranslationMiss ? (widget.initialLemma ?? '') : '',
    );
    _notesCtrl = TextEditingController();
    _variantsCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(submitWordProvider.notifier)
          .initPrefill(
            lemma: widget.initialLemma,
            searchIn: widget.initialSearchIn,
            searchMissId: widget.initialSearchMissId,
          );
      _lemmaCtrl.addListener(_onFieldEdited);
      _defCtrl.addListener(_onFieldEdited);
      _tr1Ctrl.addListener(_onFieldEdited);
    });
  }

  void _onFieldEdited() {
    ref.read(submitWordProvider.notifier).clearFieldErrors();
  }

  @override
  void dispose() {
    _lemmaCtrl.dispose();
    _defCtrl.dispose();
    _tr1Ctrl.dispose();
    _notesCtrl.dispose();
    _variantsCtrl.dispose();
    super.dispose();
  }

  List<String> _parsedVariants() => _variantsCtrl.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  List<String> _variantErrors() {
    final errors = <String>[];
    final variants = _parsedVariants();
    if (variants.length > 10) {
      errors.add('Maksimal 10 variasi per usulan');
    }
    final lemma = _lemmaCtrl.text.trim().toLowerCase();
    final seen = <String>[];
    for (final v in variants) {
      final lower = v.toLowerCase();
      if (lemma.isNotEmpty && lower == lemma) {
        errors.add('"$v" sama dengan kata yang diusulkan');
      }
      if (seen.contains(lower)) {
        errors.add('"$v" tertulis lebih dari sekali');
      }
      seen.add(lower);
    }
    return errors;
  }

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(_referenceLanguagesProvider);
    final wordClassesAsync = ref.watch(_referenceWordClassesProvider);
    final sambasLanguageId = languagesAsync.value
        ?.where((e) => e.code.toUpperCase() == 'SBS')
        .firstOrNull
        ?.id;
    final dialectsAsync = sambasLanguageId == null
        ? const AsyncValue<List<_OptionItem>>.data([])
        : ref.watch(_referenceDialectsProvider(sambasLanguageId));

    final state = ref.watch(submitWordProvider);
    final notifier = ref.read(submitWordProvider.notifier);
    final theme = context.theme;
    final isAuth = ref.watch(authStatusProvider).value?.isAuth ?? false;

    ref.listen<SubmitWordState>(submitWordProvider, (prev, next) {
      final dynamic success = next.successResult;
      if (success != null) {
        // ponytail: show lemma user typed, not server ULID (useless to contributors)
        _showSuccessDialog(context, _lemmaCtrl.text.trim());
        return;
      }

      final failure = next.failure;
      if (failure is ContributionFailure && prev?.failure != failure) {
        final message = failure.isValidationError
            ? 'Periksa kembali isian yang ditandai merah'
            : (failure.message.isNotEmpty ? failure.message : null);
        if (message != null) {
          showFToast(
            context: context,
            title: Text(message),
            variant: FToastVariant.destructive,
          );
        }
      }
    });

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Usul Kata'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.errorMessage != null) ...[
                FAlert(
                  variant: FAlertVariant.destructive,
                  title: Text(state.errorMessage!),
                ),
                const Gap(6),
              ],
              FButton(
                onPress: state.isSubmitting ? null : _submitForm,
                prefix: state.isSubmitting ? const FCircularProgress() : null,
                child: Text(
                  state.isSubmitting ? 'Mengirim...' : 'Kirim Usulan',
                ),
              ),
            ],
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        children: [
          Text(
            isAuth
                ? 'Usulan masuk antrean verifikasi sebelum tayang.'
                : 'Dikirim sebagai tamu · masuk antrean verifikasi.',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),

          FTextField(
            control: FTextFieldControl.managed(controller: _lemmaCtrl),
            label: const Text('Lemma *'),
            hint: 'Contoh: makatn',
            textInputAction: TextInputAction.next,
          ),
          _inlineError(notifier.errorFor('lemma')),
          const Gap(8),

          const _FieldCaption('Dialek'),
          if (sambasLanguageId == null)
            Text(
              'Menunggu bahasa…',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            dialectsAsync.when(
              loading: () => const _FieldLoading(),
              error: (e, _) => _BuildReferenceError(
                message: 'Gagal muat dialek',
                onRetry: () => ref.invalidate(
                  _referenceDialectsProvider(sambasLanguageId),
                ),
              ),
              data: (items) => _BuildOptionsDropdown<_OptionItem>(
                items: items,
                selected: _dialectId == null
                    ? null
                    : items.where((e) => e.id == _dialectId).firstOrNull,
                hint: items.isEmpty ? '-' : 'Opsional',
                labelFor: (e) => e.name,
                onChanged: (val) {
                  _onFieldEdited();
                  setState(() => _dialectId = val?.id);
                },
              ),
            ),
          _inlineError(notifier.errorFor('dialect_id')),
          _inlineError(notifier.errorFor('language_id')),

          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  widget.initialSearchIn == 'translation'
                      ? 'Terjemahan Sambas *'
                      : 'Terjemahan Indonesia *',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              // Aksi sekunder di samping label — bukan tombol outline yang
              // saling bersaing dengan CTA submit.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openKbbiSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.bookOpen,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(4),
                      Text(
                        'Ambil dari KBBI',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          FTextField(
            control: FTextFieldControl.managed(controller: _tr1Ctrl),
            hint: widget.initialSearchIn == 'translation'
                ? 'Padanan dalam bahasa Sambas'
                : 'Padanan dalam bahasa Indonesia',
            textInputAction: TextInputAction.next,
          ),
          _inlineError(notifier.errorFor('translation_texts')),
          const Gap(8),

          wordClassesAsync.when(
            loading: () => const _FieldLoading(),
            error: (e, _) => _BuildReferenceError(
              message: 'Gagal muat kelas kata',
              onRetry: () => ref.invalidate(_referenceWordClassesProvider),
            ),
            data: (items) {
              final selected = _wordClassId == null
                  ? null
                  : items.where((e) => e.id == _wordClassId).firstOrNull;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FieldCaption('Kelas kata *'),
                  _WordClassField(
                    selectedLabel: selected?.displayLabel,
                    onTap: () => _openWordClassSheet(items),
                  ),
                ],
              );
            },
          ),
          _inlineError(notifier.errorFor('word_class_id')),
          const Gap(8),

          const _FieldCaption('Definisi *'),
          FTextField(
            control: FTextFieldControl.managed(controller: _defCtrl),
            hint: 'Jelaskan makna kata ini',
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 3,
            minLines: 2,
          ),
          _inlineError(notifier.errorFor('definition')),

          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _variantsCtrl),
            label: const Text('Variasi penulisan'),
            hint: "ketex, kettek, kete'",
            textInputAction: TextInputAction.next,
          ),
          ..._variantErrors().map(
            (e) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                e,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.destructive,
                ),
              ),
            ),
          ),
          const Gap(8),
          FTextField(
            control: FTextFieldControl.managed(controller: _notesCtrl),
            label: const Text('Catatan'),
            hint: 'Contoh pemakaian, etimologi, dll.',
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            minLines: 1,
          ),
          const Gap(8),
          const _FieldCaption('Gambar'),
          ContributeImagesField(
            enabled: isAuth,
            images: _images,
            onChanged: (next) => setState(() => _images = next),
          ),
        ],
      ),
    );
  }

  Future<void> _openWordClassSheet(List<_OptionItem> items) async {
    final picked = await showWordClassPickerSheet(
      context,
      items: [
        for (final e in items)
          WordClassPickItem(id: e.id, name: e.name, alias: e.alias),
      ],
      selectedId: _wordClassId,
    );
    if (!mounted || picked == null) return;
    _onFieldEdited();
    setState(() => _wordClassId = picked.id);
  }

  Future<void> _openKbbiSheet() async {
    // Baca status fresh (bukan snapshot build) — loading/stale previous
    // isAuth:false setelah login sempat bikin toast palsu.
    final auth = await ref.read(authStatusProvider.future);
    if (!mounted) return;
    if (!auth.isAuth) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk ambil definisi dari KBBI'),
      );
      if (mounted) context.push('/login');
      return;
    }

    final dio = ref.read(dioProvider);
    final picked = await showKbbiDefinitionSheet(
      context,
      dio: dio,
      initialLemma: _tr1Ctrl.text.trim(),
    );
    if (!mounted || picked == null) return;

    final classes =
        ref.read(_referenceWordClassesProvider).value ?? const <_OptionItem>[];
    final matched = _matchWordClassId(
      classes,
      picked.wordClassCode,
      picked.wordClassLabel,
    );

    _onFieldEdited();
    setState(() {
      _defCtrl.text = picked.definition;
      // Lemma KBBI = padanan Indonesia
      final lemmaId = picked.lemma.trim();
      if (lemmaId.isNotEmpty) {
        _tr1Ctrl.text = lemmaId;
      }
      if (matched != null) {
        _wordClassId = matched;
      }
    });

    final parts = <String>['Definisi'];
    if (matched != null) parts.add('kelas kata');
    if (picked.lemma.trim().isNotEmpty) parts.add('terjemahan');
    showFToast(
      context: context,
      title: Text('${parts.join(', ')} diisi dari KBBI - silakan review'),
    );
  }

  Future<void> _submitForm() async {
    if (_variantErrors().isNotEmpty) return;
    if (_images.any((e) => e.uploading)) {
      showFToast(
        context: context,
        title: const Text('Tunggu upload gambar selesai'),
      );
      return;
    }
    if (_images.any((e) => e.error)) {
      showFToast(
        context: context,
        title: const Text('Hapus gambar yang gagal diunggah dulu'),
        variant: FToastVariant.destructive,
      );
      return;
    }
    final notifier = ref.read(submitWordProvider.notifier);
    final languages =
        ref.read(_referenceLanguagesProvider).value ?? const <_OptionItem>[];
    final languageId =
        languages.where((e) => e.code.toUpperCase() == 'SBS').firstOrNull?.id ??
        '';
    final translationLanguageId =
        languages.where((e) => e.code.toUpperCase() == 'IDN').firstOrNull?.id ??
        '';
    await notifier.submit(
      lemma: _lemmaCtrl.text,
      languageId: languageId,
      wordClassId: _wordClassId ?? '',
      definition: _defCtrl.text,
      dialectId: _dialectId,
      translationTexts: [_tr1Ctrl.text],
      categoryIds: [],
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      spellingVariants: _parsedVariants(),
      translationLanguageId: translationLanguageId,
      images: readySubmitImages(_images),
      searchMissId: widget.initialSearchMissId,
    );
  }

  Widget _inlineError(String? message) {
    if (message == null || message.isEmpty) return const SizedBox.shrink();
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: theme.typography.sm.copyWith(color: theme.colors.error),
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, String lemma) async {
    final theme = context.theme;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Usulan terkirim',
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lemma.isNotEmpty
                  ? '"$lemma" masuk antrean verifikasi tim.'
                  : 'Kata masuk antrean verifikasi tim.',
              style: theme.typography.sm,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Ke beranda'),
          ),
        ],
      ),
    );
  }
}

class _WordClassField extends StatelessWidget {
  const _WordClassField({required this.selectedLabel, required this.onTap});

  final String? selectedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasValue = selectedLabel != null && selectedLabel!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? selectedLabel! : 'Pilih kelas kata…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.sm.copyWith(
                    color: hasValue
                        ? theme.colors.foreground
                        : theme.colors.mutedForeground,
                  ),
                ),
              ),
              Icon(
                FLucideIcons.chevronsUpDown,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldCaption extends StatelessWidget {
  const _FieldCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.typography.sm.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colors.foreground,
        ),
      ),
    );
  }
}

class _FieldLoading extends StatelessWidget {
  const _FieldLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      child: Center(child: FCircularProgress()),
    );
  }
}

class _OptionItem {
  const _OptionItem({
    required this.id,
    required this.name,
    this.code = '',
    this.alias,
  });
  final String id;
  final String name;
  final String code;
  final String? alias;

  String get displayLabel =>
      (alias == null || alias!.isEmpty) ? name : '$name ($alias)';
}

final _referenceLanguagesProvider = FutureProvider<List<_OptionItem>>((
  ref,
) async {
  final dio = ref.watch(dioProvider);
  final resp = await dio.get<dynamic>('/api/v1/languages?is_active=true');
  final data = resp.data;
  if (data is! Map<String, dynamic>) return [];
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map<String, dynamic>>()
      .map(
        (e) => _OptionItem(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

final _referenceWordClassesProvider = FutureProvider<List<_OptionItem>>((
  ref,
) async {
  final dio = ref.watch(dioProvider);
  final resp = await dio.get<dynamic>('/api/v1/word-classes');
  final data = resp.data;
  if (data is! Map<String, dynamic>) return [];
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map<String, dynamic>>()
      .map(
        (e) => _OptionItem(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          code: e['code']?.toString() ?? '',
          alias: e['alias']?.toString(),
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

String? _matchWordClassId(
  List<_OptionItem> classes,
  String? code,
  String? label,
) {
  final normalizedCode = code?.trim().toLowerCase();
  if (normalizedCode != null && normalizedCode.isNotEmpty) {
    final byCode = classes
        .where((c) => c.code.toLowerCase() == normalizedCode)
        .firstOrNull;
    if (byCode != null) return byCode.id;
    if (normalizedCode == 'a') {
      final adj = classes
          .where((c) => c.code.toLowerCase() == 'adj')
          .firstOrNull;
      if (adj != null) return adj.id;
    }
  }
  final normalizedLabel = label?.trim().toLowerCase();
  if (normalizedLabel != null && normalizedLabel.isNotEmpty) {
    return classes
        .where((c) => c.name.toLowerCase() == normalizedLabel)
        .firstOrNull
        ?.id;
  }
  return null;
}

final _referenceDialectsProvider =
    FutureProvider.family<List<_OptionItem>, String>((ref, languageId) async {
      final dio = ref.watch(dioProvider);
      final resp = await dio.get<dynamic>(
        '/api/v1/dialects',
        queryParameters: <String, dynamic>{'language_id': languageId},
      );
      final data = resp.data;
      if (data is! Map<String, dynamic>) return [];
      final arr = data['data'];
      if (arr is! List) return [];
      return arr
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => _OptionItem(
              id: e['id']?.toString() ?? '',
              name: e['name']?.toString() ?? '(?)',
            ),
          )
          .where((e) => e.id.isNotEmpty)
          .toList(growable: false);
    });

class _BuildOptionsDropdown<T> extends StatefulWidget {
  const _BuildOptionsDropdown({
    required this.items,
    required this.selected,
    required this.hint,
    required this.labelFor,
    required this.onChanged,
  });

  final List<T> items;
  final T? selected;
  final String hint;
  final String Function(T item) labelFor;
  final ValueChanged<T?> onChanged;

  @override
  State<_BuildOptionsDropdown<T>> createState() =>
      _BuildOptionsDropdownState<T>();
}

class _BuildOptionsDropdownState<T> extends State<_BuildOptionsDropdown<T>> {
  final _controller = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controller: _controller,
          dense: true,
          visualDensity: VisualDensity.compact,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          childrenPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: theme.colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          collapsedShape: RoundedRectangleBorder(
            side: BorderSide(color: theme.colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            widget.selected != null
                ? widget.labelFor(widget.selected as T)
                : widget.hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.sm.copyWith(
              color: widget.selected != null
                  ? theme.colors.foreground
                  : theme.colors.mutedForeground,
            ),
          ),
          children: widget.items.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Text(
                      widget.hint,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ]
              : widget.items
                    .map(
                      (item) => ListTile(
                        minTileHeight: 36,
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          widget.labelFor(item),
                          style: theme.typography.sm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: widget.selected == item
                            ? Icon(
                                FLucideIcons.check,
                                size: 14,
                                color: theme.colors.primary,
                              )
                            : null,
                        onTap: () {
                          widget.onChanged(item);
                          _controller.collapse();
                        },
                      ),
                    )
                    .toList(growable: false),
        ),
      ),
    );
  }
}

class _BuildReferenceError extends StatelessWidget {
  const _BuildReferenceError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.error,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FButton(
          onPress: onRetry,
          variant: FButtonVariant.ghost,
          child: const Text('Ulangi'),
        ),
      ],
    );
  }
}
