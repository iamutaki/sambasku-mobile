import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../shared/utils/permission_helper.dart';
import '../../application/wav_trim.dart';
import '../providers/audio_player_controller.dart';
import '../providers/pronunciation_providers.dart';
import '../providers/word_detail_providers.dart';

enum _RecordPhase { idle, requestingPermission, recording, trim, submitting }

/// Durasi potongan minimum (detik) - hindari cuplikan hampir kosong.
const _minSelectionSec = 0.3;

/// Sheet rekam: izin → rekam WAV → (opsional potong) → pratinjau → kirim.
/// Rentang awal selalu seluruh rekaman; potong diam hanya lewat "Otomatis".
Future<void> showRecordPronunciationSheet(
  BuildContext context, {
  required WidgetRef ref,
  required String wordId,
  required String languageId,
  String? exampleId,
  String defaultSpeakerName = '',
}) {
  // Hentikan audio di halaman detail sebelum sheet membuka player sendiri.
  try {
    ref.read(wordDetailAudioPlayerProvider(wordId).notifier).stop();
  } catch (_) {}

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _RecordPronunciationSheet(
      wordId: wordId,
      languageId: languageId,
      exampleId: exampleId,
      defaultSpeakerName: defaultSpeakerName,
    ),
  );
}

class _RecordPronunciationSheet extends ConsumerStatefulWidget {
  const _RecordPronunciationSheet({
    required this.wordId,
    required this.languageId,
    this.exampleId,
    this.defaultSpeakerName = '',
  });

  final String wordId;
  final String languageId;
  final String? exampleId;
  final String defaultSpeakerName;

  @override
  ConsumerState<_RecordPronunciationSheet> createState() =>
      _RecordPronunciationSheetState();
}

class _RecordPronunciationSheetState
    extends ConsumerState<_RecordPronunciationSheet>
    with WidgetsBindingObserver {
  static const _maxSeconds = 60;

  final _recorder = AudioRecorder();
  /// Player khusus pratinjau - jangan pakai [wordDetailAudioPlayerProvider]
  /// supaya dispose sheet (hapus file temp) tidak merusak player detail.
  final _previewPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _previewSub;
  final _speakerCtrl = TextEditingController();
  String? _dialectId;
  _RecordPhase _phase = _RecordPhase.idle;
  String? _filePath;
  int _elapsedSec = 0;
  double _totalSec = 0;
  RangeValues _range = const RangeValues(0, 1);
  bool _trimBusy = false;
  bool _previewPlaying = false;
  List<double> _peaks = const [];
  String? _previewTrimPath;
  Timer? _tick;
  String? _error;
  bool _stoppingForLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speakerCtrl.text = widget.defaultSpeakerName.trim();
    unawaited(_previewPlayer.setLoopMode(LoopMode.off));
    _previewSub = _previewPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing =
          state.playing && state.processingState != ProcessingState.completed;
      if (playing == _previewPlaying) {
        if (state.processingState == ProcessingState.completed) {
          unawaited(_previewPlayer.seek(Duration.zero));
          unawaited(_previewPlayer.pause());
        }
        return;
      }
      setState(() => _previewPlaying = playing);
      if (state.processingState == ProcessingState.completed) {
        unawaited(_previewPlayer.seek(Duration.zero));
        unawaited(_previewPlayer.pause());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialects =
          ref.read(wordDialectsProvider(widget.languageId)).value ??
          const <DialectOption>[];
      final def = dialects.where((d) => d.isDefault).firstOrNull;
      if (def != null && mounted) {
        setState(() => _dialectId = def.id);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_phase == _RecordPhase.recording && !_stoppingForLifecycle) {
        _stoppingForLifecycle = true;
        unawaited(_stopRecording(fromLifecycle: true));
      }
      unawaited(_stopPreviewPlayer());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    unawaited(_recorder.dispose());
    _speakerCtrl.dispose();
    // Jangan panggil ref di dispose (tidak aman di Riverpod). Player detail
    // sudah di-stop saat sheet dibuka; di sini cukup lepas preview + file.
    unawaited(_disposePreviewResources());
    super.dispose();
  }

  Future<void> _stopPreviewPlayer() async {
    try {
      await _previewPlayer.stop();
    } catch (_) {}
    if (mounted && _previewPlaying) {
      setState(() => _previewPlaying = false);
    } else {
      _previewPlaying = false;
    }
  }

  Future<void> _disposePreviewResources() async {
    try {
      await _previewSub?.cancel();
    } catch (_) {}
    _previewSub = null;
    try {
      await _previewPlayer.stop();
    } catch (_) {}
    try {
      await _previewPlayer.dispose();
    } catch (_) {}
    final paths = <String?>[_filePath, _previewTrimPath];
    _filePath = null;
    _previewTrimPath = null;
    for (final p in paths) {
      if (p == null) continue;
      try {
        final f = File(p);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  Future<void> _deleteQuietly(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Hentikan preview + hapus file trim lama (dipanggil saat range berubah).
  Future<void> _invalidatePreview() async {
    await _stopPreviewPlayer();
    final preview = _previewTrimPath;
    _previewTrimPath = null;
    await _deleteQuietly(preview);
  }

  Future<void> _startRecording() async {
    setState(() {
      _error = null;
      _phase = _RecordPhase.requestingPermission;
    });

    final status = await Permission.microphone.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _phase = _RecordPhase.idle);
      if (status.isPermanentlyDenied && mounted) {
        showMicrophonePermissionDeniedDialog(context);
      } else if (mounted) {
        showFToast(
          context: context,
          title: const Text('Izin mikrofon diperlukan untuk rekam pelafalan'),
        );
      }
      return;
    }

    final hasPerm = await _recorder.hasPermission();
    if (!mounted) return;
    if (!hasPerm) {
      setState(() {
        _phase = _RecordPhase.idle;
        _error = 'Mikrofon tidak tersedia';
      });
      return;
    }

    final dir = await getTemporaryDirectory();
    // WAV PCM → bisa dipotong di Dart tanpa FFmpeg (sama pola admin web).
    final path =
        '${dir.path}/pronunciation_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: path,
    );

    if (!mounted) return;
    AnalyticsService.instance.log(
      AnalyticsEvents.audioRecordStart,
      params: {'word_id': widget.wordId},
    );
    setState(() {
      _phase = _RecordPhase.recording;
      _filePath = path;
      _elapsedSec = 0;
      _stoppingForLifecycle = false;
    });

    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      final next = _elapsedSec + 1;
      setState(() => _elapsedSec = next);
      if (next >= _maxSeconds) {
        await _stopRecording();
      }
    });
  }

  Future<void> _stopRecording({bool fromLifecycle = false}) async {
    _tick?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    final filePath = path ?? _filePath;
    if (filePath == null) {
      setState(() {
        _phase = _RecordPhase.idle;
        _error = 'Rekaman gagal disimpan';
        _stoppingForLifecycle = false;
      });
      return;
    }

    setState(() {
      _filePath = filePath;
      _phase = _RecordPhase.trim;
      _trimBusy = true;
      _error = fromLifecycle
          ? 'Rekaman dihentikan karena aplikasi tidak aktif'
          : null;
      _stoppingForLifecycle = false;
    });

    try {
      final file = File(filePath);
      final total = await wavDurationSeconds(file);
      final peaks = await computeWavPeaks(file);
      if (!mounted) return;
      // Rentang awal = seluruh rekaman. Pemotongan diam hanya lewat tombol
      // "Otomatis", supaya awal/akhir ucapan tidak terpotong sendiri.
      setState(() {
        _totalSec = total <= 0
            ? (_elapsedSec.clamp(1, _maxSeconds)).toDouble()
            : total;
        _range = RangeValues(0, _totalSec);
        _peaks = peaks;
        _trimBusy = false;
      });
    } catch (_) {
      if (!mounted) return;
      final total = _elapsedSec.clamp(1, _maxSeconds).toDouble();
      setState(() {
        _totalSec = total;
        _range = RangeValues(0, total);
        _peaks = const [];
        _trimBusy = false;
      });
    }
  }

  Future<void> _discardAndRerecord() async {
    await _invalidatePreview();
    final path = _filePath;
    _filePath = null;
    await _deleteQuietly(path);
    if (!mounted) return;
    setState(() {
      _elapsedSec = 0;
      _totalSec = 0;
      _range = const RangeValues(0, 1);
      _peaks = const [];
      _phase = _RecordPhase.idle;
      _error = null;
    });
  }

  void _onRangeChanged(RangeValues v) {
    if (v.end - v.start < _minSelectionSec) return;
    unawaited(_invalidatePreview());
    setState(() => _range = v);
  }

  /// Preview = file hasil trim (bukan ClippingAudioSource) agar tidak loop.
  Future<void> _previewClip() async {
    final path = _filePath;
    if (path == null || _trimBusy) return;
    if (_range.end - _range.start < _minSelectionSec) {
      setState(
        () => _error =
            'Potongan terlalu pendek (min ${_minSelectionSec.toStringAsFixed(1)} dtk)',
      );
      return;
    }

    // Ketuk lagi saat sedang putar → jeda.
    if (_previewPlaying) {
      await _stopPreviewPlayer();
      return;
    }

    setState(() {
      _trimBusy = true;
      _error = null;
    });
    try {
      // Pakai file trim yang sudah ada jika rentang belum berubah.
      String playPath = _previewTrimPath ?? '';
      if (playPath.isEmpty || !await File(playPath).exists()) {
        final trimmed = await trimWavFile(
          File(path),
          startSec: _range.start,
          endSec: _range.end,
        );
        if (!mounted) return;
        final oldPreview = _previewTrimPath;
        _previewTrimPath = trimmed.file.path;
        playPath = trimmed.file.path;
        if (oldPreview != null && oldPreview != playPath) {
          unawaited(_deleteQuietly(oldPreview));
        }
      }

      await _previewPlayer.stop();
      await _previewPlayer.setLoopMode(LoopMode.off);
      await _previewPlayer.setFilePath(playPath);
      await _previewPlayer.play();
      if (!mounted) return;
      setState(() => _previewPlaying = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _previewPlaying = false;
        _error = 'Gagal memutar pratinjau. Coba rekam ulang atau potong ulang.';
      });
    } finally {
      if (mounted) setState(() => _trimBusy = false);
    }
  }

  Future<void> _submit() async {
    final path = _filePath;
    final speaker = _speakerCtrl.text.trim();
    if (path == null || speaker.isEmpty) {
      setState(() => _error = 'Nama penutur wajib diisi');
      return;
    }
    if (_range.end - _range.start < _minSelectionSec) {
      setState(
        () => _error =
            'Potongan terlalu pendek (min ${_minSelectionSec.toStringAsFixed(1)} dtk)',
      );
      return;
    }

    setState(() {
      _phase = _RecordPhase.submitting;
      _error = null;
      _trimBusy = true;
    });

    await _invalidatePreview();

    late final File uploadFile;
    late final int durationMs;
    try {
      final trimmed = await trimWavFile(
        File(path),
        startSec: _range.start,
        endSec: _range.end,
      );
      uploadFile = trimmed.file;
      durationMs = trimmed.durationMs;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _RecordPhase.trim;
        _trimBusy = false;
        _error =
            'Gagal memotong audio. Sesuaikan rentang lalu coba kirim lagi.';
      });
      return;
    }

    final result = await ref
        .read(pronunciationAudioUploadServiceProvider)
        .upload(
          wordId: widget.wordId,
          audioFile: uploadFile,
          speakerName: speaker,
          durationMs: durationMs > 0 ? durationMs : 1000,
          dialectId: _dialectId,
          exampleId: widget.exampleId,
        );

    // Hapus file trim upload setelah selesai (sukses/gagal).
    if (uploadFile.path != path) {
      unawaited(_deleteQuietly(uploadFile.path));
    }

    if (!mounted) return;

    await result.match(
      (failure) async {
        if (failure.isUploadUnavailable) {
          ref
              .read(
                pronunciationUploadUnavailableProvider(widget.wordId).notifier,
              )
              .markUnavailable();
          final shown = ref
              .read(
                pronunciationUploadToastShownProvider(widget.wordId).notifier,
              )
              .markShown();
          if (shown && mounted) {
            showFToast(
              context: context,
              title: Text(failure.message),
              variant: FToastVariant.destructive,
            );
          }
          if (mounted) Navigator.of(context).pop();
          return;
        }
        setState(() {
          _phase = _RecordPhase.trim;
          _trimBusy = false;
          _error = failure.isRateLimited
              ? 'Terlalu banyak, coba lagi nanti'
              : failure.message;
        });
      },
      (_) async {
        ref.invalidate(wordDetailProvider(widget.wordId));
        if (!mounted) return;
        AnalyticsService.instance.log(
          AnalyticsEvents.audioRecordSubmit,
          params: {'word_id': widget.wordId},
        );
        showFToast(
          context: context,
          title: const Text('Terima kasih, rekaman menunggu tinjauan'),
        );
        Navigator.of(context).pop();
      },
    );
  }

  String _fmt(double sec) {
    final s = sec.floor().clamp(0, 9999);
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dialectsAsync = ref.watch(wordDialectsProvider(widget.languageId));
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final selectionSec = (_range.end - _range.start).clamp(0.0, _totalSec);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exampleId == null
                  ? 'Rekam pelafalan'
                  : 'Rekam audio contoh',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(4),
            Text(
              'Maksimal $_maxSeconds detik · WAV (bisa dipotong sebelum kirim)',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(16),
            if (_error != null) ...[
              Text(
                _error!,
                style: theme.typography.sm.copyWith(color: theme.colors.error),
              ),
              const Gap(8),
            ],
            if (_phase == _RecordPhase.idle ||
                _phase == _RecordPhase.requestingPermission)
              FButton(
                onPress: _phase == _RecordPhase.requestingPermission
                    ? null
                    : _startRecording,
                prefix: const Icon(FLucideIcons.mic),
                child: Text(
                  _phase == _RecordPhase.requestingPermission
                      ? 'Meminta izin…'
                      : 'Mulai rekam',
                ),
              ),
            if (_phase == _RecordPhase.recording) ...[
              Text(
                'Merekam… ${_elapsedSec}s / ${_maxSeconds}s',
                textAlign: TextAlign.center,
                style: theme.typography.md.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(12),
              FButton(
                variant: FButtonVariant.destructive,
                onPress: _stopRecording,
                prefix: const Icon(FLucideIcons.square),
                child: const Text('Stop'),
              ),
            ],
            if (_phase == _RecordPhase.trim ||
                _phase == _RecordPhase.submitting) ...[
              Text(
                'Potong rekaman',
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                _trimBusy
                    ? 'Menyiapkan editor…'
                    : 'Geser rentang (${_fmt(selectionSec)} dari ${_fmt(_totalSec)}). '
                          'Bagian terpilih yang akan dikirim.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              if (!_trimBusy && _totalSec > 0) ...[
                const Gap(8),
                SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _WavformPainter(
                      peaks: _peaks,
                      selectionStart: (_range.start / _totalSec).clamp(
                        0.0,
                        1.0,
                      ),
                      selectionEnd: (_range.end / _totalSec).clamp(0.0, 1.0),
                      barColor: theme.colors.mutedForeground.withValues(
                        alpha: 0.35,
                      ),
                      selectedColor: theme.colors.primary,
                      trackColor: theme.colors.secondary,
                    ),
                  ),
                ),
                if (_peaks.isEmpty) ...[
                  const Gap(4),
                  Text(
                    'Waveform tidak tersedia - geser slider untuk memotong',
                    style: theme.typography.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
                RangeSlider(
                  values: _range,
                  min: 0,
                  max: _totalSec,
                  divisions: (_totalSec * 20).clamp(10, 600).round(),
                  labels: RangeLabels(_fmt(_range.start), _fmt(_range.end)),
                  onChanged: _phase == _RecordPhase.submitting
                      ? null
                      : _onRangeChanged,
                ),
              ],
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: (_phase == _RecordPhase.submitting || _trimBusy)
                          ? null
                          : _previewClip,
                      prefix: Icon(
                        _previewPlaying ? FLucideIcons.pause : FLucideIcons.play,
                      ),
                      child: Text(_previewPlaying ? 'Jeda' : 'Pratinjau'),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: (_phase == _RecordPhase.submitting || _trimBusy)
                          ? null
                          : () async {
                              final path = _filePath;
                              if (path == null) return;
                              setState(() => _trimBusy = true);
                              await _invalidatePreview();
                              try {
                                final bounds = await detectWavSpeechBounds(
                                  File(path),
                                );
                                if (!mounted) return;
                                setState(() {
                                  final minEnd = math
                                      .min(_minSelectionSec, _totalSec)
                                      .toDouble();
                                  final start = bounds.$1
                                      .clamp(
                                        0.0,
                                        math.max(0.0, _totalSec - minEnd),
                                      )
                                      .toDouble();
                                  final end = bounds.$2
                                      .clamp(start + minEnd, _totalSec)
                                      .toDouble();
                                  _range = RangeValues(start, end);
                                  _trimBusy = false;
                                });
                              } catch (_) {
                                if (mounted) {
                                  setState(() => _trimBusy = false);
                                }
                              }
                            },
                      prefix: const Icon(FLucideIcons.scissors),
                      child: const Text('Otomatis'),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              FTextField(
                control: FTextFieldControl.managed(controller: _speakerCtrl),
                label: const Text('Nama penutur *'),
                enabled: _phase != _RecordPhase.submitting,
              ),
              const Gap(8),
              dialectsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) {
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dialek (opsional)',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final d in items)
                            GestureDetector(
                              onTap: _phase == _RecordPhase.submitting
                                  ? null
                                  : () => setState(() {
                                      _dialectId = _dialectId == d.id
                                          ? null
                                          : d.id;
                                    }),
                              child: FBadge(
                                variant: _dialectId == d.id
                                    ? FBadgeVariant.primary
                                    : FBadgeVariant.secondary,
                                child: Text(d.name),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: _phase == _RecordPhase.submitting
                          ? null
                          : _discardAndRerecord,
                      child: const Text('Rekam ulang'),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FButton(
                      onPress: (_phase == _RecordPhase.submitting || _trimBusy)
                          ? null
                          : _submit,
                      child: Text(
                        _phase == _RecordPhase.submitting ? 'Mengirim…' : 'Kirim',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const Gap(8),
            FButton(
              variant: FButtonVariant.ghost,
              onPress: _phase == _RecordPhase.submitting
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Waveform batang + highlight rentang seleksi (pola editor trim admin).
class _WavformPainter extends CustomPainter {
  _WavformPainter({
    required this.peaks,
    required this.selectionStart,
    required this.selectionEnd,
    required this.barColor,
    required this.selectedColor,
    required this.trackColor,
  });

  final List<double> peaks;
  final double selectionStart;
  final double selectionEnd;
  final Color barColor;
  final Color selectedColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = trackColor.withValues(alpha: 0.5),
    );

    if (peaks.isEmpty || size.width <= 0 || size.height <= 0) return;

    final n = peaks.length;
    final gap = 1.0;
    final barW = math.max(1.0, (size.width - gap * (n - 1)) / n);
    final midY = size.height / 2;
    final maxH = size.height * 0.85;

    for (var i = 0; i < n; i++) {
      final t = (i + 0.5) / n;
      final inSel = t >= selectionStart && t <= selectionEnd;
      final h = math.max(2.0, peaks[i] * maxH);
      final x = i * (barW + gap);
      final paint = Paint()
        ..color = inSel ? selectedColor : barColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barW / 2, midY),
            width: barW,
            height: h,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
    }

    final x0 = selectionStart * size.width;
    final x1 = selectionEnd * size.width;
    final edge = Paint()
      ..color = selectedColor
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x0, 0), Offset(x0, size.height), edge);
    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), edge);
  }

  @override
  bool shouldRepaint(covariant _WavformPainter oldDelegate) {
    return oldDelegate.peaks != peaks ||
        oldDelegate.selectionStart != selectionStart ||
        oldDelegate.selectionEnd != selectionEnd ||
        oldDelegate.barColor != barColor ||
        oldDelegate.selectedColor != selectedColor;
  }
}
