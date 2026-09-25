import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import 'cache_entry.dart';
import 'cache_policy.dart';
import 'response_cache_store.dart';

/// Persist L1 via hive_ce (§5.4.1 MOBILE_LOCAL_STRATEGI).
class ResponseCacheStoreImpl implements ResponseCacheStore {
  ResponseCacheStoreImpl();

  static const indexBoxName = 'response_cache_index';
  static const bodyBoxName = 'response_cache_body';

  Box<dynamic>? _index;
  Box<dynamic>? _body;
  bool _opened = false;

  bool get isOpen => _opened;

  @override
  Future<void> open() async {
    if (_opened) return;
    _index = await Hive.openBox<dynamic>(indexBoxName);
    _body = await Hive.openBox<dynamic>(bodyBoxName);
    _opened = true;
    await _migrateSchemaIfNeeded();
  }

  Box<dynamic> get _indexBox {
    final b = _index;
    if (b == null || !b.isOpen) {
      throw StateError('ResponseCacheStore belum open()');
    }
    return b;
  }

  Box<dynamic> get _bodyBox {
    final b = _body;
    if (b == null || !b.isOpen) {
      throw StateError('ResponseCacheStore belum open()');
    }
    return b;
  }

  Future<void> _migrateSchemaIfNeeded() async {
    final keys = _indexBox.keys.toList(growable: false);
    var wiped = false;
    for (final key in keys) {
      final raw = _indexBox.get(key);
      if (raw is! Map) {
        wiped = true;
        break;
      }
      final v = raw['schemaVersion'];
      final schema = v is int ? v : int.tryParse('$v') ?? 0;
      if (schema != CachePolicy.schemaVersion) {
        wiped = true;
        break;
      }
    }
    if (wiped && keys.isNotEmpty) {
      debugPrint(
        'ResponseCacheStore: schema mismatch → wipeAll '
        '(expected ${CachePolicy.schemaVersion})',
      );
      await wipeAll();
    }
  }

  @override
  Future<CacheEntry?> get(String key) async {
    // Belum open (mis. widget test tanpa initResponseCacheStore) → treat as miss
    // supaya CachedJsonClient tetap bisa fetch via Dio.
    if (!_opened) return null;
    final entry = CacheEntry.fromBoxes(
      key: key,
      indexRaw: _indexBox.get(key),
      bodyRaw: _bodyBox.get(key),
    );
    if (entry == null) {
      // Index/body tidak selaras - bersihkan.
      await _indexBox.delete(key);
      await _bodyBox.delete(key);
      return null;
    }
    final touched = CacheEntry(
      key: entry.key,
      body: entry.body,
      cachedAt: entry.cachedAt,
      lastAccess: DateTime.now().toUtc(),
      sizeBytes: entry.sizeBytes,
      scope: entry.scope,
      schemaVersion: entry.schemaVersion,
    );
    await _indexBox.put(key, touched.toIndexMap());
    return touched;
  }

  @override
  Future<void> put({
    required String key,
    required String body,
    CacheScope scope = CacheScope.public,
  }) async {
    if (!_opened) return;
    final now = DateTime.now().toUtc();
    final size = utf8.encode(body).length;
    final entry = CacheEntry(
      key: key,
      body: body,
      cachedAt: now,
      lastAccess: now,
      sizeBytes: size,
      scope: scope,
      schemaVersion: CachePolicy.schemaVersion,
    );
    await _bodyBox.put(key, body);
    await _indexBox.put(key, entry.toIndexMap());
    await _evictToBudget();
  }

  @override
  Future<void> delete(String key) async {
    if (!_opened) return;
    await _indexBox.delete(key);
    await _bodyBox.delete(key);
  }

  @override
  Future<void> deleteByPrefix(String prefix) async {
    if (!_opened) return;
    final keys = _indexBox.keys
        .whereType<String>()
        .where((k) => k.startsWith(prefix))
        .toList(growable: false);
    for (final k in keys) {
      await delete(k);
    }
  }

  @override
  Future<void> wipeScope(CacheScope scope) async {
    if (!_opened) return;
    final keys = <String>[];
    for (final key in _indexBox.keys) {
      if (key is! String) continue;
      final raw = _indexBox.get(key);
      if (raw is! Map) continue;
      if ('${raw['scope']}' == scope.name) keys.add(key);
    }
    for (final k in keys) {
      await delete(k);
    }
  }

  @override
  Future<void> wipeAll() async {
    if (!_opened) return;
    await _indexBox.clear();
    await _bodyBox.clear();
  }

  @override
  List<CacheEntryMeta> listMeta() {
    if (!_opened) return const [];
    final out = <CacheEntryMeta>[];
    for (final key in _indexBox.keys) {
      if (key is! String) continue;
      final meta = CacheEntryMeta.fromIndexMap(key, _indexBox.get(key));
      if (meta != null) out.add(meta);
    }
    out.sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
    return out;
  }

  @override
  CacheEntry? peek(String key) {
    if (!_opened) return null;
    return CacheEntry.fromBoxes(
      key: key,
      indexRaw: _indexBox.get(key),
      bodyRaw: _bodyBox.get(key),
    );
  }

  @override
  int get entryCount {
    if (!_opened) return 0;
    return _indexBox.length;
  }

  @override
  int get totalBytes {
    if (!_opened) return 0;
    var total = 0;
    for (final key in _indexBox.keys) {
      if (key is! String) continue;
      final raw = _indexBox.get(key);
      if (raw is! Map) continue;
      final size = raw['size'];
      total += size is int ? size : int.tryParse('$size') ?? 0;
    }
    return total;
  }

  Future<void> _evictToBudget() async {
    var total = 0;
    final scored = <({String key, DateTime lastAccess, int size})>[];
    for (final key in _indexBox.keys) {
      if (key is! String) continue;
      final raw = _indexBox.get(key);
      if (raw is! Map) continue;
      final size = raw['size'];
      final sizeBytes = size is int
          ? size
          : int.tryParse('$size') ?? 0;
      total += sizeBytes;
      final la = DateTime.tryParse('${raw['lastAccess']}') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      scored.add((key: key, lastAccess: la.toUtc(), size: sizeBytes));
    }
    if (total <= CachePolicy.maxBudgetBytes) return;

    scored.sort((a, b) => a.lastAccess.compareTo(b.lastAccess));
    for (final item in scored) {
      if (total <= CachePolicy.maxBudgetBytes) break;
      await delete(item.key);
      total -= item.size;
    }
  }
}
