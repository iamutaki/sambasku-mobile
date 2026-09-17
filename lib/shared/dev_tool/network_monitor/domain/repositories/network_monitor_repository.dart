import '../../data/models/network_request_record.dart';

abstract interface class NetworkMonitorRepository {
  List<NetworkRequestRecord> getRecords();

  Stream<List<NetworkRequestRecord>> watchRecords();

  void upsertRecord(NetworkRequestRecord record);

  void clear();
}
