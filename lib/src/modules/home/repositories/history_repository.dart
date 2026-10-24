import '../model/address.dart';

abstract interface class HistoryRepository {
  List<Address> readAll();
  Future<void> save(Address address);
}
