import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/failures/contribution_failure.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../models/submit_word_state.dart';
import '../providers/submit_word_providers.dart';
import '../widgets/contribute_images_field.dart';
import '../widgets/contribute_relations_sheet.dart';
import '../widgets/dialect_picker_sheet.dart';
import '../widgets/kbbi_definition_sheet.dart';
import '../widgets/knowledge_toggles.dart';
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

  String? _wordClassId;
  String? _dialectId;
  bool _dialectSeeded = false;
  // Independen: boleh keduanya, salah satu, atau belum ada (form kosong).
  bool _wantDefinition = false;
  bool _wantPadanan = false;
  String _savedDefinition = '';
  String _savedTranslation = '';
  ContributeRelationsDraft _relations = const ContributeRelationsDraft();
  List<ContributeImageSlot> _images = const [];

  bool get _modePicked => _wantDefinition || _wantPadanan;
  bool get _needPadanan => _wantPadanan;
  bool get _needDefinition => _wantDefinition;

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
    super.dispose();
  }

  List<String> _parseCsv(String raw) => raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  List<SubmitWordRelation> _buildRelatedWords() {
    final out = <SubmitWordRelation>[];
    for (final lemma in _parseCsv(_relations.synonymsText)) {
      out.add(SubmitWordRelation(relationType: 'synonym', lemma: lemma));
    }
    for (final lemma in _parseCsv(_relations.antonymsText)) {
      out.add(SubmitWordRelation(relationType: 'antonym', lemma: lemma));
    }
    return out;
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

    // Auto-select dialek is_default (umum) sekali; user tetap bisa ganti.
    final dialectItems = dialectsAsync.value;
    if (!_dialectSeeded &&
        _dialectId == null &&
        dialectItems != null &&
        dialectItems.isNotEmpty) {
      final def =
          dialectItems.where((e) => e.isDefault).firstOrNull ??
          dialectItems.where((e) => e.code.toLowerCase() == 'umum').firstOrNull;
      if (def != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _dialectSeeded || _dialectId != null) return;
          setState(() {
            _dialectId = def.id;
            _dialectSeeded = true;
          });
        });
      } else {
        _dialectSeeded = true;
      }
    }

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
              data: (items) {
                final selected = _dialectId == null
                    ? null
                    : items.where((e) => e.id == _dialectId).firstOrNull;
                return _SelectField(
                  selectedLabel: selected?.name,
                  hint: items.isEmpty ? '-' : 'Pilih dialek…',
                  onTap: items.isEmpty ? null : () => _openDialectSheet(items),
                );
              },
            ),
          _inlineError(notifier.errorFor('dialect_id')),
          _inlineError(notifier.errorFor('language_id')),

          const Gap(12),
          const _FieldCaption(
            'Apa yang kamu ketahui? *',
            info: 'Centang yang kamu tahu (boleh keduanya).\n\n'
                '• Definisi - uraian makna berbahasa Indonesia.\n'
                '• Padanan - satu kata/frasa setara.\n\n'
                'Form di bawah muncul sesuai centangan.',
          ),
          const Gap(8),
          KnowledgeToggles(
            wantDefinition: _wantDefinition,
            wantPadanan: _wantPadanan,
            onDefinitionChanged: _setWantDefinition,
            onPadananChanged: _setWantPadanan,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              knowledgeHint(
                wantDefinition: _wantDefinition,
                wantPadanan: _wantPadanan,
              ),
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.35,
              ),
            ),
          ),
          if (_modePicked) ...[
            if (_needPadanan) ...[
              const Gap(8),
              _FieldCaption(
                widget.initialSearchIn == 'translation'
                    ? 'Padanan Sambas *'
                    : 'Padanan Indonesia *',
                info: widget.initialSearchIn == 'translation'
                    ? 'Satu kata/frasa Sambas yang setara - bukan uraian panjang.'
                    : 'Satu kata/frasa Indonesia yang setara dengan lemma Sambas.\n\n'
                        'Contoh: “makan”. Beda dari definisi (“aktivitas memasukkan makanan ke mulut”).',
              ),
              FTextField(
                control: FTextFieldControl.managed(controller: _tr1Ctrl),
                hint: widget.initialSearchIn == 'translation'
                    ? 'Padanan dalam bahasa Sambas'
                    : 'Satu kata/frasa setara di Indonesia',
                textInputAction: TextInputAction.next,
                suffixBuilder: (context, style, _) => Padding(
                  padding: style.clearButtonPadding,
                  child: FButton.icon(
                    style: style.clearButtonStyle,
                    onPress: _openKbbiSheet,
                    child: Icon(
                      FLucideIcons.bookOpen,
                      semanticLabel: 'Ambil dari KBBI',
                    ),
                  ),
                ),
              ),
              _inlineError(notifier.errorFor('translation_texts')),
            ],

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
                    const _FieldCaption(
                      'Kelas kata *',
                      info: 'Nomina, verba, adjektiva, dsb. Bisa dibantu isi lewat ikon buku di kolom padanan.',
                    ),
                    _SelectField(
                      selectedLabel: selected?.displayLabel,
                      hint: 'Pilih kelas kata…',
                      onTap: () => _openWordClassSheet(items),
                    ),
                  ],
                );
              },
            ),
            _inlineError(notifier.errorFor('word_class_id')),

            if (_needDefinition) ...[
              const Gap(8),
              const _FieldCaption(
                'Definisi *',
                info: 'Uraian makna berbahasa Indonesia - bukan padanan satu kata.\n\n'
                    'Contoh: “aktivitas memasukkan makanan ke mulut”.',
              ),
              FTextField(
                control: FTextFieldControl.managed(controller: _defCtrl),
                hint: 'Jelaskan makna kata ini',
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                minLines: 2,
              ),
              _inlineError(notifier.errorFor('definition')),
            ],
          ],
          const Gap(12),

          const _FieldCaption(
            'Kelengkapan',
            info: 'Opsional: variasi ejaan, sinonim, antonim. Dibuka di bottomsheet.',
          ),
          _SelectField(
            selectedLabel: _relations.isEmpty ? null : _relations.summaryLabel,
            hint: 'Tambah variasi, sinonim, antonim…',
            onTap: _openRelationsSheet,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              'Opsional',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),

          const _FieldCaption(
            'Gambar',
            info: 'Opsional. Perlu login untuk mengunggah gambar.',
          ),
          ContributeImagesField(
            enabled: isAuth,
            images: _images,
            onChanged: (next) => setState(() => _images = next),
          ),
        ],
      ),
    );
  }

  void _setWantDefinition(bool next) {
    if (next == _wantDefinition) return;
    _onFieldEdited();
    setState(() {
      if (_wantDefinition && !next) {
        _savedDefinition = _defCtrl.text;
        _defCtrl.text = '-';
      } else if (!_wantDefinition && next) {
        _defCtrl.text = _savedDefinition == '-' ? '' : _savedDefinition;
      }
      _wantDefinition = next;
      if (!_wantDefinition &&
          (_defCtrl.text.trim().isEmpty || _defCtrl.text.trim() == '-')) {
        _defCtrl.text = '-';
      } else if (_wantDefinition && _defCtrl.text.trim() == '-') {
        _defCtrl.text = '';
      }
    });
  }

  void _setWantPadanan(bool next) {
    if (next == _wantPadanan) return;
    _onFieldEdited();
    setState(() {
      if (_wantPadanan && !next) {
        _savedTranslation = _tr1Ctrl.text;
        _tr1Ctrl.text = '';
      } else if (!_wantPadanan && next) {
        _tr1Ctrl.text = _savedTranslation;
      }
      _wantPadanan = next;
    });
  }

  Future<void> _openDialectSheet(List<_OptionItem> items) async {
    final picked = await showDialectPickerSheet(
      context,
      items: [
        for (final e in items)
          DialectPickItem(id: e.id, name: e.name, isDefault: e.isDefault),
      ],
      selectedId: _dialectId,
    );
    if (!mounted || picked == null) return;
    _onFieldEdited();
    setState(() {
      _dialectId = picked.id;
      _dialectSeeded = true;
    });
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

  Future<void> _openRelationsSheet() async {
    final result = await showContributeRelationsSheet(
      context,
      initial: _relations,
      lemma: _lemmaCtrl.text,
    );
    if (!mounted || result == null) return;
    _onFieldEdited();
    setState(() => _relations = result);
  }

  Future<void> _openKbbiSheet() async {
    // Baca status fresh (bukan snapshot build) - loading/stale previous
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
      _wantDefinition = true;
      _wantPadanan = true;
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
    if (picked.lemma.trim().isNotEmpty) parts.add('padanan');
    showFToast(
      context: context,
      title: Text('${parts.join(', ')} diisi dari KBBI - silakan review'),
    );
  }

  Future<void> _submitForm() async {
    if (!_modePicked) {
      showFToast(
        context: context,
        title: const Text('Centang dulu Definisi dan/atau Padanan'),
      );
      return;
    }
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
    final notes = _relations.notesText.trim();
    await notifier.submit(
      lemma: _lemmaCtrl.text,
      languageId: languageId,
      wordClassId: _wordClassId ?? '',
      definition: _needDefinition ? _defCtrl.text : '-',
      isHaveDefinition: _needDefinition,
      isHaveTranslation: _needPadanan,
      dialectId: _dialectId,
      translationTexts: _needPadanan ? [_tr1Ctrl.text] : [],
      categoryIds: [],
      notes: notes.isEmpty ? null : notes,
      spellingVariants: _parseCsv(_relations.variantsText),
      relatedWords: _buildRelatedWords(),
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

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.selectedLabel,
    required this.hint,
    required this.onTap,
  });

  final String? selectedLabel;
  final String hint;
  final VoidCallback? onTap;

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
                  hasValue ? selectedLabel! : hint,
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
  const _FieldCaption(this.text, {this.info});

  final String text;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              text,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
          ),
          if (info != null) ...[
            const Gap(4),
            _InfoTip(message: info!),
          ],
        ],
      ),
    );
  }
}

/// Ikon ⓘ - tap buka penjelasan singkat (FPopover, lebih jelas di touch
/// daripada FTooltip long-press).
class _InfoTip extends StatelessWidget {
  const _InfoTip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FPopover(
      constraints: const FPortalConstraints(maxWidth: 280),
      popoverBuilder: (context, _) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Text(
          message,
          style: theme.typography.sm.copyWith(height: 1.35),
        ),
      ),
      builder: (context, controller, child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggle,
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          FLucideIcons.info,
          size: 16,
          color: theme.colors.mutedForeground,
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
    this.isDefault = false,
  });
  final String id;
  final String name;
  final String code;
  final String? alias;
  final bool isDefault;

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
              code: e['code']?.toString() ?? '',
              isDefault: e['is_default'] == true,
            ),
          )
          .where((e) => e.id.isNotEmpty)
          .toList(growable: false);
    });

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
