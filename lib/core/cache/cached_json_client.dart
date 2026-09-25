import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../shared/dev_tool/network_monitor/network_monitor_registry.dart';
import 'cache_entry.dart';
import 'cache_policy.dart';
import 'response_cache_store.dart';

/// Cache-aside + SWR untuk envelope JSON (`Map<String, dynamic>`).
///
/// - fresh → return cache
/// - stale → return cache + revalidate background
/// - miss/expired → fetch sync
/// - fetch gagal + ada stale → return stale
/// - 429/5xx → jangan put (dipanggil lewat [shouldCacheResponse])
class CachedJsonClient {
  CachedJsonClient(this._store);

  final ResponseCacheStore _store;

  /// [fetch] harus mengembalikan body map siap di-encode (biasanya
  /// seluruh `response.data` Dio).
  Future<Map<String, dynamic>> getOrFetch({
    required String key,
    required CacheClass cacheClass,
    required Future<Map<String, dynamic>> Function() fetch,
    CacheScope scope = CacheScope.public,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final entry = await _store.get(key);
      if (entry != null) {
        final state = CachePolicy.freshness(entry, cacheClass);
        final decoded = _tryDecode(entry.body);
        if (decoded != null) {
          switch (state) {
            case CacheFreshness.fresh:
              _notifyMonitor(key, 'HIT', entry.body);
              return decoded;
            case CacheFreshness.stale:
              _notifyMonitor(key, 'STALE', entry.body);
              unawaited(_revalidate(key, cacheClass, scope, fetch));
              return decoded;
            case CacheFreshness.expired:
              break;
          }
        } else {
          await _store.delete(key);
        }
      }
    }

    try {
      final fresh = await fetch();
      await _store.put(
        key: key,
        body: jsonEncode(fresh),
        scope: scope,
      );
      return fresh;
    } catch (e, st) {
      final entry = await _store.get(key);
      if (entry != null) {
        final decoded = _tryDecode(entry.body);
        if (decoded != null) {
          final state = CachePolicy.freshness(entry, cacheClass);
          if (state == CacheFreshness.stale || state == CacheFreshness.fresh) {
            debugPrint(
              'CachedJsonClient: fetch gagal, sajikan stale ($key): $e',
            );
            _notifyMonitor(key, 'DEGRADED', entry.body);
            return decoded;
          }
        }
      }
      Error.throwWithStackTrace(e, st);
    }
  }

  void _notifyMonitor(String key, String source, String body) {
    NetworkMonitorRegistry.recordCacheServe(
      cacheKey: key,
      cacheSource: source,
      responseBody: body,
    );
  }

  Future<void> _revalidate(
    String key,
    CacheClass cacheClass,
    CacheScope scope,
    Future<Map<String, dynamic>> Function() fetch,
  ) async {
    try {
      final fresh = await fetch();
      await _store.put(
        key: key,
        body: jsonEncode(fresh),
        scope: scope,
      );
    } catch (e) {
      debugPrint('CachedJsonClient: revalidate gagal ($key): $e');
    }
  }

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      final v = jsonDecode(body);
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
    } catch (_) {}
    return null;
  }
}

/// True jika respons 2xx boleh di-put. 429/5xx jangan timpa entry bagus.
bool shouldCacheDioResponse(Response<dynamic> response) {
  final code = response.statusCode ?? 0;
  return code >= 200 && code < 300;
}

/// True untuk negative-cache 404 singkat (opsional).
bool isNegativeCacheStatus(int? statusCode) => statusCode == 404;
