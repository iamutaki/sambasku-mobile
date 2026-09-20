import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../contribution/presentation/widgets/contribute_relations_sheet.dart';

/// Draft kelengkapan usul edit = isi baru (seperti kontribusi) + tandai hapus yang ada.
class SuggestEditExtrasDraft {
  const SuggestEditExtrasDraft({
    this.relations = const ContributeRelationsDraft(),
    this.removeVariantForms = const {},
    this.removeRelationKeys = const {},
  });

  final ContributeRelationsDraft relations;
  final Set<String> removeVariantForms;
  final Set<String> removeRelationKeys;

  bool get isEmpty =>
      relations.isEmpty &&
      removeVariantForms.isEmpty &&
      removeRelationKeys.isEmpty;

  String get summaryLabel {
    final parts = <String>[];
    if (!relations.isEmpty) parts.add(relations.summaryLabel);
    if (removeVariantForms.isNotEmpty) {
      parts.add('hapus ${removeVariantForms.length} variasi');
    }
    if (removeRelationKeys.isNotEmpty) {
      parts.add('hapus ${removeRelationKeys.length} relasi');
    }
    return parts.isEmpty ? 'Belum ada' : parts.join(' · ');
  }
}

Future<SuggestEditExtrasDraft?> showSuggestEditExtrasSheet(
  BuildContext context, {
  required SuggestEditExtrasDraft initial,
  required WordDetail detail,
}) {
  return showModalBottomSheet<SuggestEditExtrasDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) =>
        _SuggestEditExtrasBody(initial: initial, detail: detail),
  );
}

class _SuggestEditExtrasBody extends StatefulWidget {
  const _SuggestEditExtrasBody({
    required this.initial,
    required this.detail,
  });

  final SuggestEditExtrasDraft initial;
  final WordDetail detail;

  @override
  State<_SuggestEditExtrasBody> createState() => _SuggestEditExtrasBodyState();
}

class _SuggestEditExtrasBodyState extends State<_SuggestEditExtrasBody> {
  late final TextEditingController _variantsCtrl;
  late final TextEditingController _synonymsCtrl;
  late final TextEditingController _antonymsCtrl;
  late final TextEditingController _notesCtrl;
  late final Set<String> _removeVariantForms;
  late final Set<String> _removeRelationKeys;

  @override
  void initState() {
    super.initState();
    final r = widget.initial.relations;
    _variantsCtrl = TextEditingController(text: r.variantsText);
    _synonymsCtrl = TextEditingController(text: r.synonymsText);
    _antonymsCtrl = TextEditingController(text: r.antonymsText);
    _notesCtrl = TextEditingController(text: r.notesText);
    _removeVariantForms = {...widget.initial.removeVariantForms};
    _removeRelationKeys = {...widget.initial.removeRelationKeys};
  }

  @override
  void dispose() {
    _variantsCtrl.dispose();
    _synonymsCtrl.dispose();
    _antonymsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      SuggestEditExtrasDraft(
        relations: ContributeRelationsDraft(
          variantsText: _variantsCtrl.text,
          synonymsText: _synonymsCtrl.text,
          antonymsText: _antonymsCtrl.text,
          notesText: _notesCtrl.text,
        ),
        removeVariantForms: _removeVariantForms,
        removeRelationKeys: _removeRelationKeys,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);
    final height = (media.size.height - media.viewInsets.bottom) * 0.85;
    final spelling = widget.detail.variants
        .where((v) => v.isSpellingVariant)
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: height.clamp(320.0, media.size.height),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.link,
                    size: 18,
                    color: theme.colors.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'Kelengkapan',
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Opsional. Kosongkan yang tidak perlu diubah.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  FTextField(
                    control: FTextFieldControl.managed(controller: _notesCtrl),
                    label: const Text('Catatan entri'),
                    hint: 'Opsional',
                    maxLines: 2,
                  ),
                  const Gap(12),
                  FTextField(
                    control:
                        FTextFieldControl.managed(controller: _variantsCtrl),
                    label: const Text('Tambah variasi'),
                    hint: 'pisah dengan koma',
                  ),
                  if (spelling.isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      'Hapus variasi yang ada',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    for (final v in spelling)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: FCheckbox(
                          value: _removeVariantForms.contains(v.form),
                          label: Text(v.form),
                          onChange: (val) {
                            setState(() {
                              if (val) {
                                _removeVariantForms.add(v.form);
                              } else {
                                _removeVariantForms.remove(v.form);
                              }
                            });
                          },
                        ),
                      ),
                  ],
                  const Gap(12),
                  FTextField(
                    control:
                        FTextFieldControl.managed(controller: _synonymsCtrl),
                    label: const Text('Tambah sinonim'),
                    hint: 'lemma yang sudah ada, pisah koma',
                  ),
                  const Gap(8),
                  FTextField(
                    control:
                        FTextFieldControl.managed(controller: _antonymsCtrl),
                    label: const Text('Tambah antonim'),
                    hint: 'lemma yang sudah ada, pisah koma',
                  ),
                  if (widget.detail.relatedWords.isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      'Hapus relasi yang ada',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    for (final r in widget.detail.relatedWords)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: FCheckbox(
                          value: _removeRelationKeys
                              .contains('${r.relationType}|${r.wordId}'),
                          label: Text('${r.relationLabel}: ${r.lemma}'),
                          onChange: (val) {
                            final key = '${r.relationType}|${r.wordId}';
                            setState(() {
                              if (val) {
                                _removeRelationKeys.add(key);
                              } else {
                                _removeRelationKeys.remove(key);
                              }
                            });
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: FButton(
                  onPress: _save,
                  child: const Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
