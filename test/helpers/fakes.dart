import 'package:fast_delivery/src/modules/home/model/address.dart';
import 'package:fast_delivery/src/modules/home/repositories/address_repository.dart';
import 'package:fast_delivery/src/modules/home/repositories/history_repository.dart';
import 'package:fast_delivery/src/modules/home/service/navigation_service.dart';

const sample = Address(
  cep: '01001-000',
  street: 'Praça da Sé',
  complement: 'lado ímpar',
  neighborhood: 'Sé',
  city: 'São Paulo',
  state: 'SP',
  ibge: '3550308',
);
const second = Address(
  cep: '01310-100',
  street: 'Avenida Paulista',
  neighborhood: 'Bela Vista',
  city: 'São Paulo',
  state: 'SP',
);

class FakeRemote implements AddressRepository {
  int calls = 0;
  String? requestedCep;
  List<String>? requestedAddress;
  Future<Address?> Function()? cepResponse;
  List<Address> matches = [sample, second];
  @override
  Future<Address?> findByCep(String cep) async {
    calls++;
    requestedCep = cep;
    return cepResponse == null ? sample : await cepResponse!();
  }

  @override
  Future<List<Address>> findByAddress(
    String state,
    String city,
    String street,
  ) async {
    calls++;
    requestedAddress = [state, city, street];
    return matches;
  }
}

class MemoryHistory implements HistoryRepository {
  final entries = <String, Address>{};
  bool failSave = false;
  bool failRead = false;
  @override
  List<Address> readAll() {
    if (failRead) throw StateError('read failed');
    return entries.values.toList()
      ..sort((a, b) => b.consultedAt!.compareTo(a.consultedAt!));
  }

  @override
  Future<void> save(Address address) async {
    if (failSave) throw StateError('disk full');
    entries[address.id] = address;
  }
}

class FakeGeocoder implements Geocoder {
  String? query;
  List<Coordinates> locations = [const Coordinates(-23.55, -46.63)];
  bool fail = false;
  @override
  Future<List<Coordinates>> locate(String address) async {
    query = address;
    if (fail) throw StateError('geocoder unavailable');
    return locations;
  }
}

class FakeMaps implements MapsGateway {
  Coordinates? destination;
  int opened = 0;
  bool empty = false;
  bool failOpen = false;
  @override
  Future<List<NavigationOption>> installed(Coordinates target) async {
    destination = target;
    return empty
        ? []
        : [
            NavigationOption('Mapa de teste', () async {
              if (failOpen) throw StateError('map unavailable');
              opened++;
            }),
          ];
  }
}
