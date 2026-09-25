import 'cache_entry.dart';

/// Kontrak L1 - implementasi Hive di [ResponseCacheStoreImpl].
abstract class ResponseCacheStore {
  Future<void> open();

  Future<CacheEntry?> get(String key);

  Future<void> put({
    required String key,
    required String body,
    CacheScope scope = CacheScope.public,
  });

  Future<void> delete(String key);

  /// Hapus semua key yang cocok prefix (mis. `GET|/api/v1/words/latest`).
  Future<void> deleteByPrefix(String prefix);

  Future<void> wipeScope(CacheScope scope);

  Future<void> wipeAll();

  /// Dev / diagnostics: daftar meta tanpa menyentuh [CacheEntry.lastAccess].
  List<CacheEntryMeta> listMeta();

  /// Dev / diagnostics: baca entry tanpa menyentuh lastAccess (bukan hot path).
  CacheEntry? peek(String key);

  int get entryCount;

  int get totalBytes;
}
