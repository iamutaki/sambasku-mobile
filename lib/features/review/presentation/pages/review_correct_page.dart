import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../data/review_correct_body.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/review_providers.dart';
import 'review_forbidden_page.dart';

class ReviewCorrectPage extends ConsumerStatefulWidget {
  const ReviewCorrectPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ReviewCorrectPage> createState() => _ReviewCorrectPageState();
}

class _MeaningEdit {
  _MeaningEdit({required String definition, required String translation})
    : definitionCtrl = TextEditingController(text: definition),
      translationCtrl = TextEditingController(text: translation);

  final TextEditingController definitionCtrl;
  final TextEditingController translationCtrl;

  void dispose() {
    definitionCtrl.dispose();
    translationCtrl.dispose();
  }
}

class _ReviewCorrectPageState extends ConsumerState<ReviewCorrectPage> {
  final _lemma = TextEditingController();
  final _notes = TextEditingController();
  final _comment = TextEditingController();
  final _childFields = <String, TextEditingController>{};
  final _meanings = <_MeaningEdit>[];
  String _wordType = 'word';
  bool _publish = true;
  bool _seeded = false;
  bool _busy = false;
  bool _childPrimary = false;
  bool _hasPrimary = false;

  @override
  void dispose() {
    _lemma.dispose();
    _notes.dispose();
    _comment.dispose();
    for (final controller in _childFields.values) {
      controller.dispose();
    }
    for (final meaning in _meanings) {
      meaning.dispose();
    }
    super.dispose();
  }

  void _seed(ReviewDetail detail) {
    if (_seeded) return;
    _seeded = true;
    if (detail.contribution.entityType == 'word') {
      _lemma.text = detail.entity['lemma']?.toString() ?? '';
      _notes.text = detail.entity['notes']?.toString() ?? '';
      _wordType = detail.entity['wordType']?.toString() ?? 'word';
      final meanings = detail.entity['meanings'];
      if (meanings is List) {
        for (final raw in meanings) {
          if (raw is! Map) continue;
          final translations = raw['translations'];
          final first = translations is List && translations.isNotEmpty && translations.first is Map
              ? translations.first['translationText']?.toString() ?? ''
              : '';
          _meanings.add(
            _MeaningEdit(
              definition: raw['definition']?.toString() ?? '',
              translation: first,
            ),
          );
        }
      }
      return;
    }
    final data = detail.entity['data'];
    if (data is Map) {
      for (final entry in data.entries) {
        if (entry.key == 'is_primary') {
          _hasPrimary = true;
          _childPrimary = entry.value == true;
          continue;
        }
        _childFields[entry.key.toString()] = TextEditingController(
          text: entry.value?.toString() ?? '',
        );
      }
    }
  }

  Future<void> _submit(ReviewDetail detail) async {
    if (_busy) return;
    final type = detail.contribution.entityType;
    if (type == 'meaning') return;
    setState(() => _busy = true);
    final body = type == 'word' ? _wordBody(detail) : _childBody(type);
    final result = await ref.read(reviewRepositoryProvider).correct(detail.contribution.id, body);
    if (!mounted) return;
    setState(() => _busy = false);
    result.match((failure) {
      if (failure.isForbidden) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ReviewForbiddenPage(message: failure.message),
          ),
        );
        return;
      }
      final message = failure.isAlreadyDecided
          ? 'Usulan ini sudah diproses'
          : failure.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      if (failure.isAlreadyDecided) {
        invalidateReviewQueue(ref);
        context.pop();
      }
    }, (decision) {
      invalidateReviewQueue(ref);
      AnalyticsService.instance.log(
        AnalyticsEvents.reviewCorrect,
        params: {'contribution_id': detail.contribution.id},
      );
      final label = decision.status == 'pending'
          ? 'Koreksi disimpan. Usulan tetap menunggu.'
          : 'Koreksi disimpan dan usulan ditutup.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
      context.pop();
      context.pop();
    });
  }

  Map<String, dynamic> _wordBody(ReviewDetail detail) {
    return buildWordCorrectBody(
      entity: detail.entity,
      lemma: _lemma.text,
      notes: _notes.text,
      wordType: _wordType,
      meaningEdits: [
        for (final meaning in _meanings)
          (definition: meaning.definitionCtrl.text, translation: meaning.translationCtrl.text),
      ],
      publish: _publish,
      comment: _comment.text,
    );
  }

  Map<String, dynamic> _childBody(String entityType) {
    String? text(String key) {
      final value = _childFields[key]?.text.trim() ?? '';
      return value.isEmpty ? null : value;
    }

    final comment = _comment.text.trim();
    final shared = <String, dynamic>{
      'entity_type': entityType,
      'publish': _publish,
      if (comment.isNotEmpty) 'comment': comment,
    };
    return switch (entityType) {
      'pronunciation' => {
        ...shared,
        'notation': text('notation') ?? 'ipa',
        'value': text('value') ?? '',
        if (text('dialect_id') != null) 'dialect_id': text('dialect_id'),
        if (text('audio_url') != null) 'audio_url': text('audio_url'),
        if (text('speaker_name') != null) 'speaker_name': text('speaker_name'),
        if (text('notes') != null) 'notes': text('notes'),
      },
      'word_image' => {
        ...shared,
        'url': text('url') ?? '',
        'provider_file_id': text('provider_file_id') ?? '',
        if (text('alt_text') != null) 'alt_text': text('alt_text'),
        'is_primary': _childPrimary,
      },
      'word_audio' => {
        ...shared,
        'is_primary': _childPrimary,
        if (text('dialect_id') != null) 'dialect_id': text('dialect_id'),
        if (text('speaker_name') != null) 'speaker_name': text('speaker_name'),
      },
      _ => {
        ...shared,
        'source_sentence': text('source_sentence') ?? '',
        if (text('target_sentence') != null) 'target_sentence': text('target_sentence'),
        if (text('source_type') != null) 'source_type': text('source_type'),
        if (text('notes') != null) 'notes': text('notes'),
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(reviewDetailProvider(widget.id));
    final failure = detailAsync.hasError ? detailAsync.error : null;
    if (failure is ReviewFailure && failure.isForbidden) {
      return ReviewForbiddenPage(message: failure.message);
    }
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Koreksi'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: detailAsync.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) {
          return Center(
            child: Text(error is ReviewFailure ? error.message : 'Gagal memuat usulan'),
          );
        },
        data: (detail) {
          _seed(detail);
          if (detail.contribution.entityType == 'meaning') {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Koreksi langsung tidak didukung untuk makna. Tolak usulan ini, lalu minta pengirim mengusulkan ulang.',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (detail.contribution.entityType == 'word') ..._wordFields() else ..._childForm(),
              const Gap(12),
              FTextField(
                control: .managed(controller: _comment),
                enabled: !_busy,
                label: const Text('Catatan (opsional)'),
              ),
              const Gap(12),
              Row(
                children: [
                  const Expanded(child: Text('Langsung terbitkan dan verifikasi')),
                  FSwitch(
                    semanticsLabel: 'Langsung terbitkan dan verifikasi',
                    value: _publish,
                    enabled: !_busy,
                    onChange: (value) => setState(() => _publish = value),
                  ),
                ],
              ),
              const Gap(16),
              FButton(
                onPress: _busy ? null : () => _submit(detail),
                prefix: _busy ? const FCircularProgress() : null,
                child: Text(_publish ? 'Simpan dan terbitkan' : 'Simpan, tetap menunggu'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _wordFields() {
    return [
      FTextField(
        control: .managed(controller: _lemma),
        enabled: !_busy,
        label: const Text('Lemma'),
      ),
      const Gap(12),
      FTextField(
        control: .managed(controller: _notes),
        enabled: !_busy,
        label: const Text('Catatan kata'),
      ),
      const Gap(12),
      for (var i = 0; i < _meanings.length; i++) ...[
        Text('Makna ${i + 1}'),
        const Gap(6),
        FTextField(
          control: .managed(controller: _meanings[i].definitionCtrl),
          enabled: !_busy,
          label: const Text('Definisi'),
        ),
        const Gap(8),
        FTextField(
          control: .managed(controller: _meanings[i].translationCtrl),
          enabled: !_busy,
          label: const Text('Padanan'),
        ),
        const Gap(12),
      ],
    ];
  }

  List<Widget> _childForm() {
    const labels = <String, String>{
      'notation': 'Notasi',
      'value': 'Pelafalan',
      'dialect_id': 'Dialek',
      'audio_url': 'URL audio',
      'speaker_name': 'Penutur',
      'notes': 'Catatan',
      'url': 'URL gambar',
      'provider_file_id': 'Berkas gambar',
      'alt_text': 'Teks alternatif',
      'source_sentence': 'Kalimat sumber',
      'target_sentence': 'Kalimat terjemahan',
      'source_type': 'Sumber',
    };
    return [
      for (final entry in _childFields.entries) ...[
        FTextField(
          control: .managed(controller: entry.value),
          enabled: !_busy,
          label: Text(labels[entry.key] ?? entry.key),
        ),
        const Gap(12),
      ],
      if (_hasPrimary)
        Row(
          children: [
            const Expanded(child: Text('Utama')),
            FSwitch(
              semanticsLabel: 'Utama',
              value: _childPrimary,
              enabled: !_busy,
              onChange: (value) => setState(() => _childPrimary = value),
            ),
          ],
        ),
    ];
  }
}
