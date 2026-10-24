import '../model/address.dart';

abstract interface class AddressRepository {
  Future<Address?> findByCep(String cep);
  Future<List<Address>> findByAddress(String state, String city, String street);
}
