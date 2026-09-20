import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/presentation/widgets/contribute_images_field.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';

const _reasonOptions = <({String code, String label})>[
  (code: 'typo', label: 'Kesalahan penulisan'),
  (code: 'inaccurate_definition', label: 'Definisi kurang tepat'),
  (code: 'missing_example', label: 'Kurang contoh'),
  (code: 'missing_relation', label: 'Relasi/sinonim kurang'),
  (code: 'image_issue', label: 'Gambar kurang/salah'),
  (code: 'other', label: 'Lainnya'),
];

/// Form usul perubahan kata tayang - POST /api/v1/words/:id/suggest-edit.
class SuggestEditPage extends ConsumerStatefulWidget {
  const SuggestEditPage({super.key, required this.wordId});

  final String wordId;

  @override
  ConsumerState<SuggestEditPage> createState() => _SuggestEditPageState();
}

class _SuggestEditPageState extends ConsumerState<SuggestEditPage> {
  final _lemmaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _definitionCtrl = TextEditingController();
  final _reasonTextCtrl = TextEditingController();
  final _newVariantsCtrl = TextEditingController();
  final _newSynonymsCtrl = TextEditingController();
  final _newAntonymsCtrl = TextEditingController();

  bool _prefilled = false;
  bool _submitting = false;
  String? _error;
  String _reasonCode = 'typo';

  final Set<String> _removeVariantForms = {};
  final Set<String> _removeRelationKeys = {}; // relationType|wordId
  final Set<String> _removeImageIds = {};
  String? _setPrimaryImageId;
  List<ContributeImageSlot> _newImages = [];

  @override
  void dispose() {
    _lemmaCtrl.dispose();
    _notesCtrl.dispose();
    _definitionCtrl.dispose();
    _reasonTextCtrl.dispose();
    _newVariantsCtrl.dispose();
    _newSynonymsCtrl.dispose();
    _newAntonymsCtrl.dispose();
    super.dispose();
  }

  void _prefillOnce(WordDetail detail) {
    if (_prefilled) return;
    _prefilled = true;
    _lemmaCtrl.text = detail.lemma;
    _notesCtrl.text = detail.notes ?? '';
    if (detail.meanings.isNotEmpty) {
      _definitionCtrl.text = detail.meanings.first.definition ?? '';
    }
  }

  List<String> _csvParts(String raw) => raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<String?> _resolveLemmaId(Dio dio, String lemma, String excludeId) async {
    final res = await dio.get<Map<String, dynamic>>(
      '/api/v1/words/search',
      queryParameters: {'q': lemma, 'limit': 10},
    );
    final data = res.data?['data'];
    if (data is! List) return null;
    for (final item in data) {
      if (item is! Map) continue;
      final id = item['id'] as String?;
      final l = (item['lemma'] as String?)?.trim().toLowerCase();
      if (id != null && id != excludeId && l == lemma.trim().toLowerCase()) {
        return id;
      }
    }
    return null;
  }

  Future<void> _submit(WordDetail detail) async {
    final reasonText = _reasonTextCtrl.text.trim();
    if (_reasonCode == 'other' && reasonText.length < 3) {
      setState(() => _error = 'Untuk Lainnya, isi detail minimal 3 karakter');
      return;
    }

    final proposed = <String, dynamic>{};
    final lemma = _lemmaCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final definition = _definitionCtrl.text.trim();

    if (lemma.isNotEmpty && lemma != detail.lemma) {
      proposed['lemma'] = lemma;
    }
    if (notes != (detail.notes ?? '')) {
      proposed['notes'] = notes;
    }
    if (detail.meanings.isNotEmpty &&
        definition.isNotEmpty &&
        definition != (detail.meanings.first.definition ?? '')) {
      proposed['meanings'] = [
        {
          'meaning_id': detail.meanings.first.id,
          'action': 'update',
          'definition': definition,
        },
      ];
    }

    final variants = <Map<String, dynamic>>[];
    for (final form in _csvParts(_newVariantsCtrl.text)) {
      if (form.toLowerCase() == detail.lemma.toLowerCase()) continue;
      variants.add({
        'action': 'add',
        'form': form,
        'variant_type': 'alternative',
      });
    }
    for (final form in _removeVariantForms) {
      variants.add({'action': 'remove', 'form': form, 'variant_type': 'alternative'});
    }
    if (variants.isNotEmpty) proposed['variants'] = variants;

    final relations = <Map<String, dynamic>>[];
    for (final key in _removeRelationKeys) {
      final parts = key.split('|');
      if (parts.length != 2) continue;
      relations.add({
        'action': 'remove',
        'relation_type': parts[0],
        'word_id': parts[1],
      });
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);

      for (final lemmaName in _csvParts(_newSynonymsCtrl.text)) {
        final id = await _resolveLemmaId(dio, lemmaName, detail.id);
        if (id == null) {
          setState(() {
            _error = 'Sinonim "$lemmaName" tidak ditemukan (pakai lemma kata yang sudah ada)';
            _submitting = false;
          });
          return;
        }
        relations.add({
          'action': 'add',
          'relation_type': 'synonym',
          'word_id': id,
        });
      }
      for (final lemmaName in _csvParts(_newAntonymsCtrl.text)) {
        final id = await _resolveLemmaId(dio, lemmaName, detail.id);
        if (id == null) {
          setState(() {
            _error = 'Antonim "$lemmaName" tidak ditemukan (pakai lemma kata yang sudah ada)';
            _submitting = false;
          });
          return;
        }
        relations.add({
          'action': 'add',
          'relation_type': 'antonym',
          'word_id': id,
        });
      }
      if (relations.isNotEmpty) proposed['relations'] = relations;

      final images = <Map<String, dynamic>>[];
      for (final slot in _newImages) {
        final dto = slot.dto;
        if (dto == null) continue;
        images.add({
          'action': 'add',
          'url': dto.url,
          'provider_file_id': dto.providerFileId,
          'alt_text': dto.altText,
          'is_primary': dto.isPrimary,
        });
      }
      for (final id in _removeImageIds) {
        images.add({'action': 'remove', 'image_id': id});
      }
      if (_setPrimaryImageId != null && !_removeImageIds.contains(_setPrimaryImageId)) {
        images.add({'action': 'set_primary', 'image_id': _setPrimaryImageId});
      }
      if (images.isNotEmpty) proposed['images'] = images;

      if (proposed.isEmpty) {
        setState(() {
          _error = 'Isi minimal satu perubahan';
          _submitting = false;
        });
        return;
      }

      await dio.post<Map<String, dynamic>>(
        '/api/v1/words/${widget.wordId}/suggest-edit',
        data: {
          'proposed_changes': proposed,
          'reason_code': _reasonCode,
          if (reasonText.isNotEmpty) 'reason_text': reasonText,
        },
      );
      if (!mounted) return;
      showFToast(
        context: context,
        title: const Text('Usulan terkirim - menunggu review'),
      );
      context.pop();
    } on DioException catch (e) {
      final data = e.response?.data;
      var msg = 'Gagal mengirim usulan';
      if (data is Map && data['message'] is String) {
        msg = data['message'] as String;
      }
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStatusProvider).value;
    final detailAsync = ref.watch(wordDetailProvider(widget.wordId));
    final theme = context.theme;

    if (auth?.isAuth != true) {
      return FScaffold(
        header: FHeader.nested(
          title: const Text('Usulkan Perubahan'),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(
          child: FButton(
            onPress: () => context.push('/login'),
            child: const Text('Masuk dulu untuk mengusulkan'),
          ),
        ),
      );
    }

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Usulkan Perubahan'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FButton(
            onPress: _submitting
                ? null
                : () {
                    final d = detailAsync.asData?.value;
                    if (d != null) _submit(d);
                  },
            prefix: _submitting ? const FCircularProgress() : null,
            child: Text(_submitting ? 'Mengirim...' : 'Kirim Usulan'),
          ),
        ),
      ),
      child: detailAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (e, _) => Center(child: Text('$e')),
        data: (detail) {
          _prefillOnce(detail);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'Ubah hanya field yang ingin diusulkan. Admin mereview sebelum tayang.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(12),
              FTextField(
                control: FTextFieldControl.managed(controller: _lemmaCtrl),
                label: const Text('Lemma'),
              ),
              const Gap(8),
              FTextField(
                control: FTextFieldControl.managed(controller: _notesCtrl),
                label: const Text('Catatan'),
                maxLines: 2,
              ),
              const Gap(8),
              FTextField(
                control: FTextFieldControl.managed(controller: _definitionCtrl),
                label: const Text('Definisi (makna pertama)'),
                maxLines: 3,
                minLines: 2,
              ),
              const Gap(16),
              Text('Variasi penulisan', style: theme.typography.md),
              const Gap(4),
              FTextField(
                control: FTextFieldControl.managed(controller: _newVariantsCtrl),
                label: const Text('Tambah varian (pisah koma)'),
                hint: 'ketex, kettek',
              ),
              ...detail.variants.where((v) => v.isSpellingVariant).map((v) {
                final selected = _removeVariantForms.contains(v.form);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FCheckbox(
                    value: selected,
                    label: Text('Hapus: ${v.form}'),
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
                );
              }),
              const Gap(12),
              Text('Relasi (link kata existing)', style: theme.typography.md),
              const Gap(4),
              FTextField(
                control: FTextFieldControl.managed(controller: _newSynonymsCtrl),
                label: const Text('Tambah sinonim (lemma, koma)'),
              ),
              const Gap(8),
              FTextField(
                control: FTextFieldControl.managed(controller: _newAntonymsCtrl),
                label: const Text('Tambah antonim (lemma, koma)'),
              ),
              ...detail.relatedWords.map((r) {
                final key = '${r.relationType}|${r.wordId}';
                final selected = _removeRelationKeys.contains(key);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FCheckbox(
                    value: selected,
                    label: Text('Hapus ${r.relationLabel}: ${r.lemma}'),
                    onChange: (val) {
                      setState(() {
                        if (val) {
                          _removeRelationKeys.add(key);
                        } else {
                          _removeRelationKeys.remove(key);
                        }
                      });
                    },
                  ),
                );
              }),
              const Gap(12),
              Text('Gambar', style: theme.typography.md),
              const Gap(4),
              ContributeImagesField(
                enabled: true,
                images: _newImages,
                onChanged: (next) => setState(() => _newImages = next),
              ),
              ...detail.images.map((img) {
                final remove = _removeImageIds.contains(img.id);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FCheckbox(
                        value: remove,
                        label: Text(
                          'Hapus gambar${img.isPrimary ? ' (utama)' : ''}',
                        ),
                        description: Text(
                          img.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onChange: (val) {
                          setState(() {
                            if (val) {
                              _removeImageIds.add(img.id);
                              if (_setPrimaryImageId == img.id) {
                                _setPrimaryImageId = null;
                              }
                            } else {
                              _removeImageIds.remove(img.id);
                            }
                          });
                        },
                      ),
                      if (!remove && !img.isPrimary) ...[
                        const Gap(4),
                        FButton(
                          variant: .outline,
                          onPress: () =>
                              setState(() => _setPrimaryImageId = img.id),
                          child: Text(
                            _setPrimaryImageId == img.id
                                ? 'Akan dijadikan utama'
                                : 'Jadikan utama',
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const Gap(16),
              Text('Alasan usulan *', style: theme.typography.md),
              const Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reasonOptions.map((o) {
                  final selected = _reasonCode == o.code;
                  return FButton(
                    variant: selected ? .primary : .outline,
                    onPress: () => setState(() => _reasonCode = o.code),
                    child: Text(o.label),
                  );
                }).toList(),
              ),
              const Gap(8),
              FTextField(
                control: FTextFieldControl.managed(controller: _reasonTextCtrl),
                label: Text(
                  _reasonCode == 'other'
                      ? 'Detail alasan *'
                      : 'Detail tambahan (opsional)',
                ),
                maxLines: 3,
                minLines: 2,
              ),
              if (_error != null) ...[
                const Gap(8),
                Text(
                  _error!,
                  style: theme.typography.sm.copyWith(color: theme.colors.error),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
