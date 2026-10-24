import 'package:mobx/mobx.dart';
import '../../home/model/address.dart';
import '../../home/service/address_service.dart';

part 'history_controller.g.dart';

class HistoryController = HistoryControllerBase with _$HistoryController;

abstract class HistoryControllerBase with Store {
  HistoryControllerBase(this._service);
  final AddressService _service;
  @observable
  ObservableList<Address> entries = ObservableList<Address>();
  @observable
  String? error;
  @action
  void load() {
    error = null;
    try {
      entries = ObservableList.of(_service.history());
    } catch (_) {
      error = 'Não foi possível carregar o histórico local.';
    }
  }
}
