import 'data/models/network_request_record.dart';
import 'data/repositories/in_memory_network_monitor_repository.dart';
import 'domain/usecases/clear_network_records_use_case.dart';
import 'domain/usecases/observe_network_records_use_case.dart';

abstract final class NetworkMonitorRegistry {
  static final InMemoryNetworkMonitorRepository repository =
      InMemoryNetworkMonitorRepository();

  static final ObserveNetworkRecordsUseCase observeRecords =
      ObserveNetworkRecordsUseCase(repository);

  static final ClearNetworkRecordsUseCase clearRecords =
      ClearNetworkRecordsUseCase(repository);

  static int _cacheCounter = 0;

  /// Catat sajian dari ResponseCacheStore (bukan Dio) ke Network Monitor.
  ///
  /// [cacheSource]: `HIT` | `STALE` | `DEGRADED`.
  /// [cacheKey]: format `METHOD|path|query` dari [buildCacheKey].
  static void recordCacheServe({
    required String cacheKey,
    required String cacheSource,
    String? responseBody,
  }) {
    final parts = cacheKey.split('|');
    final method = parts.isNotEmpty ? parts[0] : 'GET';
    final path = parts.length > 1 ? parts[1] : cacheKey;
    final query = parts.length > 2 ? parts[2] : '';
    final now = DateTime.now();
    final queryParams = <String, String>{};
    if (query.isNotEmpty) {
      for (final pair in query.split('&')) {
        final i = pair.indexOf('=');
        if (i <= 0) continue;
        queryParams[pair.substring(0, i)] = pair.substring(i + 1);
      }
    }

    repository.upsertRecord(
      NetworkRequestRecord(
        id: 'cache_${now.microsecondsSinceEpoch}_${_cacheCounter++}',
        startedAt: now,
        finishedAt: now,
        durationMs: 0,
        method: method,
        url: query.isEmpty ? path : '$path?$query',
        path: path,
        queryParameters: queryParams,
        statusCode: 200,
        responseBody: responseBody,
        cacheSource: cacheSource,
      ),
    );
  }
}
