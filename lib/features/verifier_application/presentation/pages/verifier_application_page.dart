import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../../auth/presentation/pages/register_page.dart';
import '../../../contribution/data/providers/contribution_data_providers.dart';
import '../../domain/entities/verifier_application.dart';
import '../providers/verifier_application_providers.dart';

const _platforms = <String, String>{
  'instagram': 'Instagram',
  'facebook': 'Facebook',
  'tiktok': 'TikTok',
  'youtube': 'YouTube',
  'x': 'X',
  'website': 'Website',
};

const _maxScreenshotMb = 5;
const _uploadFolder = '/verifier-applications';

String _nationalPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('62')) digits = digits.substring(2);
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits;
}

String _normalizeUsername(String raw) {
  var value = raw.trim();
  while (value.startsWith('@')) {
    value = value.substring(1).trim();
  }
  return value;
}

class _SocialDraft {
  const _SocialDraft({
    required this.platform,
    this.username = '',
    this.screenshotUrl,
    this.screenshotFileId,
    this.localPath,
    this.uploading = false,
    this.error = false,
  });

  final String platform;
  final String username;
  final String? screenshotUrl;
  final String? screenshotFileId;
  final String? localPath;
  final bool uploading;
  final bool error;

  bool get screenshotReady =>
      (screenshotUrl ?? '').isNotEmpty &&
      (screenshotFileId ?? '').isNotEmpty &&
      !uploading &&
      !error;

  _SocialDraft copyWith({
    String? platform,
    String? username,
    String? screenshotUrl,
    String? screenshotFileId,
    String? localPath,
    bool? uploading,
    bool? error,
    bool clearRemoteScreenshot = false,
  }) {
    return _SocialDraft(
      platform: platform ?? this.platform,
      username: username ?? this.username,
      screenshotUrl: clearRemoteScreenshot
          ? null
          : (screenshotUrl ?? this.screenshotUrl),
      screenshotFileId: clearRemoteScreenshot
          ? null
          : (screenshotFileId ?? this.screenshotFileId),
      localPath: localPath ?? this.localPath,
      uploading: uploading ?? this.uploading,
      error: error ?? this.error,
    );
  }
}

class VerifierApplicationPage extends HookConsumerWidget {
  const VerifierApplicationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifierApplicationProvider);
    final phone = useTextEditingController();
    final address = useTextEditingController();
    final social = useState<List<_SocialDraft>>([
      const _SocialDraft(platform: 'instagram'),
    ]);
    useListenable(phone);
    useListenable(address);

    ref.listen(verifierApplicationProvider.select((s) => s.application), (
      _,
      next,
    ) {
      if (next == null) return;
      phone.text = _nationalPhone(next.phone);
      address.text = next.address;
      social.value = next.socialLinks.isEmpty
          ? [const _SocialDraft(platform: 'instagram')]
          : next.socialLinks
                .map(
                  (l) => _SocialDraft(
                    platform: l.platform,
                    username: l.username,
                    screenshotUrl: l.screenshot.url,
                    screenshotFileId: l.screenshot.providerFileId,
                  ),
                )
                .toList();
    });

    ref.listen(verifierApplicationProvider.select((s) => s.successMessage), (
      _,
      next,
    ) {
      if (next == null) return;
      showFToast(context: context, title: Text(next));
      if (context.canPop()) context.pop();
    });

    final pending = state.application?.isPending == true;
    final rejected = state.application?.isRejected == true;
    final approved = state.application?.isApproved == true;
    final readOnly = pending || state.isSubmitting;

    final links = <SocialLink>[];
    var allReady = social.value.isNotEmpty;
    for (final row in social.value) {
      final username = _normalizeUsername(row.username);
      if (username.length < 2 || !row.screenshotReady) {
        allReady = false;
        continue;
      }
      links.add(
        SocialLink(
          platform: row.platform,
          username: username,
          screenshot: SocialScreenshot(
            url: row.screenshotUrl!,
            providerFileId: row.screenshotFileId!,
          ),
        ),
      );
    }
    final canSubmit =
        !readOnly &&
        !state.isLoading &&
        phone.text.trim().isNotEmpty &&
        address.text.trim().length >= 10 &&
        allReady &&
        links.length == social.value.length;

    void submit() {
      ref
          .read(verifierApplicationProvider.notifier)
          .submit(
            phone: phone.text.trim(),
            address: address.text.trim(),
            socialLinks: links,
          );
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Jadi verifikator'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: SafeArea(
        child: state.isLoading
            ? const Center(child: FCircularProgress())
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  if (approved)
                    const FAlert(
                      title: Text('Pengajuan disetujui'),
                      subtitle: Text(
                        'Pengajuan Anda disetujui. Masuk ulang agar peran baru aktif.',
                      ),
                    )
                  else ...[
                    const FAlert(
                      title: Text('Tentang peran verifikator'),
                      subtitle: Text(
                        'Verifikator meninjau usulan kata warga sebelum tayang di kamus (setujui, tolak, atau koreksi) agar entri tetap akurat. Nomor HP dan alamat dipakai admin untuk menghubungi dan memastikan pemohon orang nyata dari komunitas. Username media sosial plus tangkapan layar membuktikan akun itu milik pemohon, bukan tautan kosong. Data ini tidak tampil di profil publik.',
                      ),
                    ),
                    const Gap(12),
                    if (pending) ...[
                      const FAlert(
                        title: Text('Menunggu review'),
                        subtitle: Text(
                          'Pengajuan sedang ditinjau admin. Form terkunci sampai ada keputusan.',
                        ),
                      ),
                      const Gap(12),
                    ],
                    if (rejected) ...[
                      FAlert(
                        variant: .destructive,
                        title: const Text('Pengajuan ditolak'),
                        subtitle: Text(
                          state.application?.adminComment?.trim().isNotEmpty ==
                                  true
                              ? state.application!.adminComment!
                              : 'Perbaiki data lalu kirim ulang.',
                        ),
                      ),
                      const Gap(12),
                    ],
                    FTextField(
                      control: .managed(controller: phone),
                      enabled: !readOnly,
                      label: const Text('No. HP'),
                      hint: '81234567890',
                      keyboardType: .phone,
                      textInputAction: .next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixBuilder: (context, style, variants) => Padding(
                        padding: const EdgeInsets.only(left: 12, right: 4),
                        child: Text(
                          kPhoneCountryPrefix,
                          style: context.theme.typography.sm.copyWith(
                            color: context.theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    FTextField(
                      control: .managed(controller: address),
                      enabled: !readOnly,
                      label: const Text('Alamat'),
                      hint: 'Alamat lengkap tempat tinggal/domisili',
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 3,
                      maxLines: 6,
                    ),
                    const Gap(16),
                    Text(
                      'Media sosial (minimal 1)',
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                    for (var i = 0; i < social.value.length; i++) ...[
                      if (i > 0) const Gap(16),
                      _SocialRow(
                        key: ValueKey('social-$i'),
                        index: i,
                        draft: social.value[i],
                        enabled: !readOnly,
                        canRemove: social.value.length > 1 && !readOnly,
                        onChanged: (next) {
                          final copy = [...social.value];
                          copy[i] = next;
                          social.value = copy;
                        },
                        onRemove: () {
                          final copy = [...social.value]..removeAt(i);
                          social.value = copy;
                        },
                      ),
                    ],
                    if (!readOnly && social.value.length < 5) ...[
                      const Gap(12),
                      FButton(
                        variant: .outline,
                        onPress: () {
                          social.value = [
                            ...social.value,
                            const _SocialDraft(platform: 'instagram'),
                          ];
                        },
                        child: const Text('Tambah akun'),
                      ),
                    ],
                    if (state.errorMessage != null) ...[
                      const Gap(12),
                      FAlert(
                        variant: .destructive,
                        title: Text(state.errorMessage!),
                      ),
                    ],
                    const Gap(16),
                    if (!pending)
                      FButton(
                        onPress: canSubmit ? submit : null,
                        prefix: state.isSubmitting
                            ? const FCircularProgress()
                            : null,
                        child: Text(
                          state.isSubmitting
                              ? 'Mengirim...'
                              : rejected
                              ? 'Kirim ulang'
                              : 'Kirim pengajuan',
                        ),
                      ),
                    const Gap(8),
                    Text(
                      'Nomor HP dan alamat hanya untuk admin, tidak tampil di profil publik.',
                      textAlign: .center,
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SocialRow extends ConsumerStatefulWidget {
  const _SocialRow({
    super.key,
    required this.index,
    required this.draft,
    required this.enabled,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _SocialDraft draft;
  final bool enabled;
  final bool canRemove;
  final ValueChanged<_SocialDraft> onChanged;
  final VoidCallback onRemove;

  @override
  ConsumerState<_SocialRow> createState() => _SocialRowState();
}

class _SocialRowState extends ConsumerState<_SocialRow> {
  late final TextEditingController _username;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.draft.username);
  }

  @override
  void didUpdateWidget(covariant _SocialRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.username != widget.draft.username &&
        _username.text != widget.draft.username) {
      _username.text = widget.draft.username;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _pickPlatform() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        return Material(
          color: Theme.of(sheetContext).colorScheme.surface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Pilih platform',
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(12),
                  FTileGroup(
                    children: [
                      for (final entry in _platforms.entries)
                        FTile(
                          title: Text(entry.value),
                          suffix: entry.key == widget.draft.platform
                              ? Icon(
                                  FLucideIcons.check,
                                  size: 16,
                                  color: theme.colors.primary,
                                )
                              : null,
                          onPress: () =>
                              Navigator.of(sheetContext).pop(entry.key),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected != null && selected != widget.draft.platform) {
      widget.onChanged(
        widget.draft.copyWith(platform: selected, username: _username.text),
      );
    }
  }

  void _openScreenshotPicker() {
    if (!widget.enabled || widget.draft.uploading) return;
    showImageSheetDrawer(
      context,
      picker: _picker,
      filePicker: false,
      onPicked: _handlePicked,
    );
  }

  Future<void> _handlePicked(File file) async {
    if (!mounted) return;
    try {
      final size = await file.length();
      if (size > _maxScreenshotMb * 1024 * 1024) {
        if (mounted) _toast('Gambar melebihi $_maxScreenshotMb MB');
        return;
      }

      widget.onChanged(
        widget.draft.copyWith(
          username: _username.text,
          localPath: file.path,
          uploading: true,
          error: false,
          clearRemoteScreenshot: true,
        ),
      );

      final result = await ref
          .read(wordImageUploadServiceProvider)
          .uploadFile(file, folder: _uploadFolder);
      if (!mounted) return;

      result.match(
        (failure) {
          widget.onChanged(
            widget.draft.copyWith(
              username: _username.text,
              localPath: file.path,
              uploading: false,
              error: true,
              clearRemoteScreenshot: true,
            ),
          );
          _toast(failure.message);
        },
        (dto) {
          widget.onChanged(
            widget.draft.copyWith(
              username: _username.text,
              localPath: file.path,
              screenshotUrl: dto.url,
              screenshotFileId: dto.providerFileId,
              uploading: false,
              error: false,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('[ImageSheet] verifier screenshot $e');
      if (mounted) _toast('Gagal memproses gambar');
    }
  }

  void _toast(String message) {
    showFToast(
      context: context,
      title: Text(message),
      variant: FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = _platforms[widget.draft.platform] ?? widget.draft.platform;
    final theme = context.theme;
    final hint = widget.draft.platform == 'website'
        ? 'nama situs atau akun'
        : 'nama atau username';

    return Column(
      crossAxisAlignment: .start,
      children: [
        FTileGroup(
          children: [
            FTile(
              title: Text(label),
              subtitle: Text(
                widget.index == 0 ? 'Platform' : 'Platform ${widget.index + 1}',
              ),
              suffix: Icon(
                FLucideIcons.chevronDown,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
              onPress: widget.enabled ? _pickPlatform : null,
            ),
          ],
        ),
        const Gap(8),
        FTextField(
          control: .managed(
            controller: _username,
            onChange: (value) =>
                widget.onChanged(widget.draft.copyWith(username: value.text)),
          ),
          enabled: widget.enabled,
          label: const Text('Nama / username'),
          hint: hint,
          keyboardType: TextInputType.text,
          textInputAction: .next,
        ),
        const Gap(8),
        Text(
          'Screenshot profil',
          style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(6),
        _ScreenshotSlot(
          draft: widget.draft,
          enabled: widget.enabled,
          onTap: _openScreenshotPicker,
        ),
        if (widget.canRemove) ...[
          const Gap(4),
          Align(
            alignment: .centerRight,
            child: FButton(
              variant: .ghost,
              onPress: widget.onRemove,
              prefix: const Icon(FLucideIcons.trash, size: 16),
              child: const Text('Hapus akun'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScreenshotSlot extends StatelessWidget {
  const _ScreenshotSlot({
    required this.draft,
    required this.enabled,
    required this.onTap,
  });

  final _SocialDraft draft;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final local = draft.localPath;
    final remote = draft.screenshotUrl;

    Widget preview;
    if (local != null && local.isNotEmpty) {
      preview = Image.file(
        File(local),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: theme.colors.muted,
          child: Icon(FLucideIcons.image, color: theme.colors.mutedForeground),
        ),
      );
    } else if (remote != null && remote.isNotEmpty) {
      preview = Image.network(
        remote,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: theme.colors.muted,
          child: Icon(FLucideIcons.image, color: theme.colors.mutedForeground),
        ),
      );
    } else {
      preview = ColoredBox(
        color: theme.colors.muted,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(FLucideIcons.camera, color: theme.colors.mutedForeground),
            const Gap(4),
            Text(
              'Kamera / galeri',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: preview,
              ),
            ),
            if (draft.uploading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x88000000),
                  child: Center(child: FCircularProgress()),
                ),
              ),
            if (draft.error)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x88B91C1C),
                  child: Icon(
                    FLucideIcons.circleAlert,
                    color: theme.colors.primaryForeground,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
