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
}
