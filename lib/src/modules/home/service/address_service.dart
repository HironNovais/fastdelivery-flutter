import '../../../shared/components/app_exception.dart';
import '../model/address.dart';
import '../repositories/address_repository.dart';
import '../repositories/history_repository.dart';
import 'address_validation.dart';

class AddressService {
  AddressService(this._remote, this._history, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final AddressRepository _remote;
  final HistoryRepository _history;
  final DateTime Function() _now;
  Future<Address?> findByCep(String input) {
    final error = AddressValidation.cep(input);
    if (error != null) throw AppException(error);
    return _remote.findByCep(AddressValidation.cleanCep(input));
  }

  Future<List<Address>> findByAddress(
    String state,
    String city,
    String street,
  ) {
    final error =
        AddressValidation.state(state) ??
        AddressValidation.city(city) ??
        AddressValidation.street(street);
    if (error != null) throw AppException(error);
    return _remote.findByAddress(
      state.toUpperCase(),
      city.trim(),
      street.trim(),
    );
  }

  Future<Address> record(Address address) async {
    final entry = address.consulted(_now());
    await _history.save(entry);
    return entry;
  }

  List<Address> history() => _history.readAll();
}
