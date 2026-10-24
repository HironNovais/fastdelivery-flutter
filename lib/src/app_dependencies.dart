import 'package:hive/hive.dart';
import 'http/dio_client.dart';
import 'modules/history/controller/history_controller.dart';
import 'modules/home/controller/home_controller.dart';
import 'modules/home/model/address.dart';
import 'modules/home/repositories/hive_history_repository.dart';
import 'modules/home/repositories/viacep_repository.dart';
import 'modules/home/service/address_service.dart';
import 'modules/home/service/navigation_service.dart';

class AppDependencies {
  AppDependencies(this.addresses, this.navigation);
  factory AppDependencies.production(Box<Address> history) => AppDependencies(
    AddressService(
      ViaCepRepository(createDio()),
      HiveHistoryRepository(history),
    ),
    NavigationService(NativeGeocoder(), NativeMapsGateway()),
  );
  final AddressService addresses;
  final NavigationService navigation;
  HomeController home() => HomeController(addresses, navigation);
  HistoryController history() => HistoryController(addresses);
}
