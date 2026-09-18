import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../models/submit_word_state.dart';
import '../providers/submit_word_providers.dart';

class ContributePage extends ConsumerStatefulWidget {
  const ContributePage({super.key, this.initialLemma, this.initialSearchIn});

  final String? initialLemma;
  final String? initialSearchIn;

  @override
  ConsumerState<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends ConsumerState<ContributePage> {
  late final TextEditingController _lemmaCtrl;
  late final TextEditingController _defCtrl;
  late final TextEditingController _tr1Ctrl;
  late final TextEditingController _notesCtrl;

  String? _languageId;
  String? _wordClassId;
  String? _dialectId;

  @override
  void initState() {
    super.initState();
    _lemmaCtrl = TextEditingController(text: widget.initialLemma ?? '');
    _defCtrl = TextEditingController();
    _tr1Ctrl = TextEditingController();
    _notesCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(submitWordProvider.notifier)
          .initPrefill(
            lemma: widget.initialLemma,
            searchIn: widget.initialSearchIn,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(_referenceLanguagesProvider);
    final wordClassesAsync = ref.watch(_referenceWordClassesProvider);
    final dialectsAsync = _languageId == null
        ? const AsyncValue<List<_OptionItem>>.data([])
        : ref.watch(_referenceDialectsProvider(_languageId!));

    final state = ref.watch(submitWordProvider);
    final notifier = ref.read(submitWordProvider.notifier);
    final theme = context.theme;

    ref.listen<SubmitWordState>(submitWordProvider, (prev, next) {
      final dynamic success = next.successResult;
      if (success != null) {
        final wid = success.wordId?.toString() ?? '';
        _showSuccessDialog(context, wid);
      }
    });

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Usul Kata Baru'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          FAlert(
            title: const Text('Kirim usul sebagai tamu'),
            subtitle: const Text(
              'Kata Anda akan masuk antrean verifikasi tim. Limit 5 usul per jam per perangkat.',
            ),
          ),
          const Gap(12),

          // --- Lemma ---
          _buildLabel('Kata', required: true),
          FTextField(
            control: FTextFieldControl.managed(controller: _lemmaCtrl),
            hint: 'Contoh: makatn',
            textInputAction: TextInputAction.next,
            prefixBuilder: (ctx, s, v) => FTextField.prefixIconBuilder(
              ctx,
              s,
              v,
              const Icon(FLucideIcons.type),
            ),
          ),
          _buildInlineError(notifier.errorFor('lemma')),

          const Gap(12),
          // --- Language Dropdown ---
          _buildLabel('Bahasa', required: true),
          languagesAsync.when(
            loading: () => const SizedBox(
              height: 44,
              child: Center(child: FCircularProgress()),
            ),
            error: (e, _) => _BuildReferenceError(
              message: 'Gagal muat bahasa: $e',
              onRetry: () => ref.invalidate(_referenceLanguagesProvider),
            ),
            data: (items) => _BuildOptionsDropdown<_OptionItem>(
              items: items,
              selected: _languageId == null
                  ? null
                  : items.where((e) => e.id == _languageId).firstOrNull,
              hint: '-- Pilih Bahasa --',
              labelFor: (e) => '${e.name} (${e.code.toUpperCase()})',
              onChanged: (val) {
                _onFieldEdited();
                setState(() {
                  _languageId = val?.id;
                  _dialectId = null;
                });
              },
            ),
          ),
          _buildInlineError(notifier.errorFor('language_id')),

          const Gap(12),
          // --- Word Class ---
          _buildLabel('Kelas Kata (Word Class)', required: true),
          wordClassesAsync.when(
            loading: () => const SizedBox(
              height: 44,
              child: Center(child: FCircularProgress()),
            ),
            error: (e, _) => _BuildReferenceError(
              message: 'Gagal muat kelas kata: $e',
              onRetry: () => ref.invalidate(_referenceWordClassesProvider),
            ),
            data: (items) => _BuildOptionsDropdown<_OptionItem>(
              items: items,
              selected: _wordClassId == null
                  ? null
                  : items.where((e) => e.id == _wordClassId).firstOrNull,
              hint: '-- Pilih Kelas Kata --',
              labelFor: (e) => e.name,
              onChanged: (val) {
                _onFieldEdited();
                setState(() => _wordClassId = val?.id);
              },
            ),
          ),
          _buildInlineError(notifier.errorFor('word_class_id')),

          const Gap(12),
          // --- Dialect (optional, only after language selected) ---
          _buildLabel('Dialek'),
          if (_languageId == null)
            Text(
              'Pilih bahasa terlebih dahulu',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else
            dialectsAsync.when(
              loading: () => const SizedBox(
                height: 44,
                child: Center(child: FCircularProgress()),
              ),
              error: (e, _) => _BuildReferenceError(
                message: 'Gagal muat dialek: $e',
                onRetry: () =>
                    ref.invalidate(_referenceDialectsProvider(_languageId!)),
              ),
              data: (items) => _BuildOptionsDropdown<_OptionItem>(
                items: items,
                selected: _dialectId == null
                    ? null
                    : items.where((e) => e.id == _dialectId).firstOrNull,
                hint: items.isEmpty
                    ? 'Tidak ada dialek untuk bahasa ini'
                    : '-- Pilih Dialek (opsional) --',
                labelFor: (e) => e.name,
                onChanged: (val) {
                  _onFieldEdited();
                  setState(() => _dialectId = val?.id);
                },
              ),
            ),
          _buildInlineError(notifier.errorFor('dialect_id')),

          const Gap(12),
          // --- Definition ---
          _buildLabel('Definisi / Makna', required: true),
          FTextField(
            control: FTextFieldControl.managed(controller: _defCtrl),
            hint: 'Jelaskan makna kata ini dalam bahasa Indonesia atau Sambas.',
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 4,
            minLines: 3,
          ),
          _buildInlineError(notifier.errorFor('definition')),

          const Gap(12),
          // --- Translation 1 ---
          _buildLabel('Terjemahan (minimal 1)', required: true),
          FTextField(
            control: FTextFieldControl.managed(controller: _tr1Ctrl),
            hint: widget.initialSearchIn == 'translation'
                ? 'Kata dalam Bahasa Sambas...'
                : 'Kata dalam Bahasa Indonesia...',
            textInputAction: TextInputAction.done,
            prefixBuilder: (ctx, s, v) => FTextField.prefixIconBuilder(
              ctx,
              s,
              v,
              const Icon(FLucideIcons.languages),
            ),
          ),
          _buildInlineError(notifier.errorFor('translation_texts')),

          const Gap(12),
          // --- Notes ---
          _buildLabel('Catatan (opsional)'),
          FTextField(
            control: FTextFieldControl.managed(controller: _notesCtrl),
            hint: 'Contoh penggunaan, etimologi, atau catatan lain.',
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            minLines: 2,
          ),

          const Gap(20),
          if (state.errorMessage != null) ...[
            FAlert(
              variant: FAlertVariant.destructive,
              title: Text(state.errorMessage!),
            ),
            const Gap(12),
          ],

          FButton(
            onPress: state.isSubmitting ? null : _submitForm,
            prefix: state.isSubmitting
                ? const FCircularProgress()
                : const Icon(FLucideIcons.sendHorizontal),
            child: Text(
              state.isSubmitting ? 'Mengirim...' : 'Kirim Usulan Kata',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    final notifier = ref.read(submitWordProvider.notifier);
    await notifier.submit(
      lemma: _lemmaCtrl.text,
      languageId: _languageId ?? '',
      wordClassId: _wordClassId ?? '',
      definition: _defCtrl.text,
      dialectId: _dialectId,
      translationTexts: [_tr1Ctrl.text],
      categoryIds: [],
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            text,
            style: theme.typography.sm.copyWith(
              color: theme.colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (required) ...[
            const Gap(4),
            Text(
              '*',
              style: theme.typography.sm.copyWith(color: theme.colors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineError(String? message) {
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

  Future<void> _showSuccessDialog(BuildContext context, String wordId) async {
    final theme = context.theme;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Usulan Dikirim!',
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              FLucideIcons.badgeCheck,
              size: 48,
              color: theme.colors.primary,
            ),
            const Gap(12),
            Text(
              'Kata Anda masuk antrean verifikasi tim kami.',
              style: theme.typography.sm,
            ),
            const Gap(8),
            if (wordId.isNotEmpty)
              Text(
                'ID usulan: $wordId',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Reference dropdown items: inline FutureProvider (MVP, bisa pindah ke
// feature module nanti tapi ini cukup untuk jalan cepat).
// =============================================================================

class _OptionItem {
  const _OptionItem({required this.id, required this.name, this.code = ''});
  final String id;
  final String name;
  final String code;
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
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
});

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

/// Fallback ExpansionTile-based dropdown (pasti compile, tidak bergantung
/// widget Forui select yang API-nya berbeda-beda antar versi).
class _BuildOptionsDropdown<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.colors.border, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        collapsedShape: RoundedRectangleBorder(
          side: BorderSide(color: theme.colors.border, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        childrenPadding: const EdgeInsets.symmetric(vertical: 4),
        title: Text(
          selected != null ? labelFor(selected as T) : hint,
          style: theme.typography.sm.copyWith(
            color: selected != null
                ? theme.colors.foreground
                : theme.colors.mutedForeground,
          ),
        ),
        children: items.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    hint,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ]
            : items
                  .map(
                    (item) => ListTile(
                      minTileHeight: 36,
                      dense: true,
                      title: Text(labelFor(item), style: theme.typography.sm),
                      trailing: selected == item
                          ? Icon(
                              FLucideIcons.check,
                              size: 16,
                              color: theme.colors.primary,
                            )
                          : null,
                      onTap: () {
                        onChanged(item);
                        if (context.mounted) Navigator.of(context).maybePop();
                      },
                    ),
                  )
                  .toList(growable: false),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Gap(8),
        FButton(
          onPress: onRetry,
          variant: FButtonVariant.ghost,
          prefix: const Icon(FLucideIcons.refreshCw),
          child: const Text('Coba lagi'),
        ),
      ],
    );
  }
}
