import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cached_json_client.dart';
import 'response_cache_store.dart';
import 'response_cache_store_impl.dart';

part 'cache_providers.g.dart';

/// Dipanggil dari [main] sebelum [runApp] setelah [Hive.initFlutter].
final responseCacheStoreSingleton = ResponseCacheStoreImpl();

Future<void> initResponseCacheStore() async {
  await Hive.initFlutter();
  await responseCacheStoreSingleton.open();
}

@Riverpod(keepAlive: true)
ResponseCacheStore responseCacheStore(Ref ref) => responseCacheStoreSingleton;

@Riverpod(keepAlive: true)
CachedJsonClient cachedJsonClient(Ref ref) =>
    CachedJsonClient(ref.watch(responseCacheStoreProvider));
