import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../data/share_background_repository.dart';
import '../domain/share_models.dart';

/// Jelajah / cari foto latar (default: Unsplash popular, search kosong).
Future<ShareBackground?> showShareImageExplorer(
  BuildContext context, {
  required ShareBackgroundRepository backgrounds,
}) {
  return showModalBottomSheet<ShareBackground>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ImageExplorerBody(backgrounds: backgrounds),
  );
}

class _ImageExplorerBody extends StatefulWidget {
  const _ImageExplorerBody({required this.backgrounds});

  final ShareBackgroundRepository backgrounds;

  @override
  State<_ImageExplorerBody> createState() => _ImageExplorerBodyState();
}

class _ImageExplorerBodyState extends State<_ImageExplorerBody> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final String _provider = 'unsplash';
  String _mode = 'popular'; // popular | relevant
  String _activeQuery = '';
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _degraded = false;
  bool _hasMore = true;
  List<ShareBackground> _items = const [];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _page = 1;
      _hasMore = true;
      _items = const [];
    });
    final isSearch = _activeQuery.trim().isNotEmpty;
    final result = await widget.backgrounds.listBackgrounds(
      isSearch ? _activeQuery : '',
      page: 1,
      sort: isSearch ? 'relevant' : 'popular',
      provider: _provider,
      limit: 12,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _degraded = result.degraded;
      _items = result.items;
      _page = result.page;
      _hasMore = result.items.length >= 12;
      _mode = isSearch ? 'relevant' : 'popular';
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final next = _page + 1;
    final isSearch = _mode == 'relevant';
    final result = await widget.backgrounds.listBackgrounds(
      isSearch ? _activeQuery : '',
      page: next,
      sort: _mode,
      provider: _provider,
      limit: 12,
    );
    if (!mounted) return;
    setState(() {
      _loadingMore = false;
      if (result.items.isEmpty) {
        _hasMore = false;
      } else {
        _items = [..._items, ...result.items];
        _page = next;
        _hasMore = result.items.length >= 12;
      }
    });
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim();
    setState(() => _activeQuery = q);
    _loadInitial();
  }

  void _onClearSearch() {
    _searchCtrl.clear();
    setState(() => _activeQuery = '');
    _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final media = MediaQuery.of(context);

    return SizedBox(
      height: media.size.height * 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Image Explorer',
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.secondary,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: theme.colors.border),
                        ),
                        child: Text(
                          'Unsplash',
                          style: theme.typography.sm.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: theme.colors.foreground),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Cari foto…',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: _onClearSearch,
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Gap(8),
                FButton(
                  mainAxisSize: MainAxisSize.min,
                  onPress: _onSearch,
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _mode == 'popular'
                  ? 'Foto populer'
                  : 'Hasil: $_activeQuery',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _degraded
                                ? 'Foto tidak tersedia. Coba lagi nanti.'
                                : 'Tidak ada hasil.',
                            textAlign: TextAlign.center,
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: _items.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= _items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final item = _items[i];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pop(item),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => ColoredBox(
                                  color: theme.colors.secondary,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
