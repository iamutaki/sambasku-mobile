import '../../data/models/network_request_record.dart';
import '../repositories/network_monitor_repository.dart';

class ObserveNetworkRecordsUseCase {
  const ObserveNetworkRecordsUseCase(this._repository);

  final NetworkMonitorRepository _repository;

  Stream<List<NetworkRequestRecord>> call() => _repository.watchRecords();
}
