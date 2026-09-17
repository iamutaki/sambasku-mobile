import '../repositories/network_monitor_repository.dart';

class ClearNetworkRecordsUseCase {
  const ClearNetworkRecordsUseCase(this._repository);

  final NetworkMonitorRepository _repository;

  void call() => _repository.clear();
}
