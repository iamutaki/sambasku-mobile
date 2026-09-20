import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/pages/register_page.dart';
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

String _nationalPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('62')) digits = digits.substring(2);
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits;
}

class VerifierApplicationPage extends HookConsumerWidget {
  const VerifierApplicationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifierApplicationProvider);
    final phone = useTextEditingController();
    final address = useTextEditingController();
    final social = useState<List<({String platform, String url})>>([
      (platform: 'instagram', url: ''),
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
          ? [(platform: 'instagram', url: '')]
          : next.socialLinks
                .map((l) => (platform: l.platform, url: l.url))
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
    final links = social.value
        .map((r) => SocialLink(platform: r.platform, url: r.url.trim()))
        .where((l) => l.url.isNotEmpty)
        .toList();
    final canSubmit =
        !readOnly &&
        !state.isLoading &&
        phone.text.trim().isNotEmpty &&
        address.text.trim().length >= 10 &&
        links.isNotEmpty;

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
                    if (pending)
                      const FAlert(
                        title: Text('Menunggu review'),
                        subtitle: Text(
                          'Pengajuan sedang ditinjau admin. Form terkunci sampai ada keputusan.',
                        ),
                      ),
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
                        platform: social.value[i].platform,
                        url: social.value[i].url,
                        enabled: !readOnly,
                        canRemove: social.value.length > 1 && !readOnly,
                        onPlatform: (platform) {
                          final next = [...social.value];
                          next[i] = (platform: platform, url: next[i].url);
                          social.value = next;
                        },
                        onUrl: (url) {
                          final next = [...social.value];
                          next[i] = (platform: next[i].platform, url: url);
                          social.value = next;
                        },
                        onRemove: () {
                          final next = [...social.value]..removeAt(i);
                          social.value = next;
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
                            (platform: 'instagram', url: ''),
                          ];
                        },
                        child: const Text('Tambah tautan'),
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

String _urlHint(String platform) => switch (platform) {
  'instagram' => 'https://instagram.com/username',
  'facebook' => 'https://facebook.com/username',
  'tiktok' => 'https://tiktok.com/@username',
  'youtube' => 'https://youtube.com/@channel',
  'x' => 'https://x.com/username',
  'website' => 'https://contoh.com',
  _ => 'https://...',
};

class _SocialRow extends StatefulWidget {
  const _SocialRow({
    super.key,
    required this.index,
    required this.platform,
    required this.url,
    required this.enabled,
    required this.canRemove,
    required this.onPlatform,
    required this.onUrl,
    required this.onRemove,
  });

  final int index;
  final String platform;
  final String url;
  final bool enabled;
  final bool canRemove;
  final ValueChanged<String> onPlatform;
  final ValueChanged<String> onUrl;
  final VoidCallback onRemove;

  @override
  State<_SocialRow> createState() => _SocialRowState();
}

class _SocialRowState extends State<_SocialRow> {
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.url);
  }

  @override
  void didUpdateWidget(covariant _SocialRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && _url.text != widget.url) {
      _url.text = widget.url;
    }
  }

  @override
  void dispose() {
    _url.dispose();
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
                          suffix: entry.key == widget.platform
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
    if (selected != null && selected != widget.platform) {
      widget.onPlatform(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _platforms[widget.platform] ?? widget.platform;
    final theme = context.theme;

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
            controller: _url,
            onChange: (value) => widget.onUrl(value.text),
          ),
          enabled: widget.enabled,
          label: const Text('Tautan'),
          hint: _urlHint(widget.platform),
          keyboardType: TextInputType.url,
          textInputAction: .next,
        ),
        if (widget.canRemove) ...[
          const Gap(4),
          Align(
            alignment: .centerRight,
            child: FButton(
              variant: .ghost,
              onPress: widget.onRemove,
              prefix: const Icon(FLucideIcons.trash, size: 16),
              child: const Text('Hapus tautan'),
            ),
          ),
        ],
      ],
    );
  }
}
