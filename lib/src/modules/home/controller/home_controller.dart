import 'package:mobx/mobx.dart';

import '../../../shared/components/app_exception.dart';
import '../model/address.dart';
import '../service/address_service.dart';
import '../service/navigation_service.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  HomeControllerBase(this._service, this._navigation);
  final AddressService _service;
  final NavigationService _navigation;

  @observable
  bool loading = false;
  @observable
  bool routeLoading = false;
  @observable
  Address? current;
  @observable
  Address? last;
  @observable
  ObservableList<Address> results = ObservableList<Address>();
  @observable
  ObservableList<Address> recent = ObservableList<Address>();
  @observable
  String? error;
  @observable
  bool notFound = false;
  @observable
  bool isLocal = false;

  @action
  void refreshHistory() {
    try {
      final entries = _service.history();
      last = entries.isEmpty ? null : entries.first;
      recent = ObservableList.of(entries.take(3));
    } catch (failure) {
      _report(failure);
    }
  }

  @action
  void resetSearch() {
    if (loading) return;
    current = null;
    results.clear();
    notFound = false;
    error = null;
    isLocal = false;
  }

  @action
  Future<void> searchByCep(String cep) => _search(() async {
    final address = await _service.findByCep(cep);
    return address == null ? [] : [address];
  }, selectFirst: true);

  @action
  Future<void> searchByAddress(String state, String city, String street) =>
      _search(() => _service.findByAddress(state, city, street));

  Future<void> _search(
    Future<List<Address>> Function() query, {
    bool selectFirst = false,
  }) async {
    if (loading) return;
    resetSearch();
    loading = true;
    try {
      final found = await query();
      notFound = found.isEmpty;
      if (selectFirst && found.isNotEmpty) {
        current = found.first;
        await _record(found.first);
      } else {
        results = ObservableList.of(found);
      }
    } catch (failure) {
      _report(failure);
    } finally {
      loading = false;
    }
  }

  Future<void> _record(Address address) async {
    current = await _service.record(address);
    refreshHistory();
  }

  @action
  Future<void> selectResult(Address address) async {
    if (loading) return;
    error = null;
    loading = true;
    current = address;
    results.clear();
    isLocal = false;
    try {
      await _record(address);
    } catch (failure) {
      _report(failure);
    } finally {
      loading = false;
    }
  }

  @action
  void openLocal(Address address) {
    if (loading) return;
    resetSearch();
    current = address;
    isLocal = true;
    // Rever um registro offline não representa uma nova consulta ao ViaCEP.
  }

  @action
  Future<List<NavigationOption>> prepareRoute(Address address) async {
    if (routeLoading) return [];
    routeLoading = true;
    error = null;
    try {
      return await _navigation.prepare(address);
    } catch (failure) {
      _report(failure);
      return [];
    } finally {
      routeLoading = false;
    }
  }

  @action
  Future<void> openRoute(NavigationOption option) async {
    if (routeLoading) return;
    routeLoading = true;
    error = null;
    try {
      await _navigation.open(option);
    } catch (failure) {
      _report(failure);
    } finally {
      routeLoading = false;
    }
  }

  void _report(Object failure) {
    error = failure is AppException
        ? failure.message
        : 'Ocorreu um erro inesperado. Tente novamente.';
  }
}
