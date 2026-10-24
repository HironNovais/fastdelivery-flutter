import 'package:hive_flutter/hive_flutter.dart';
import '../../modules/home/model/address.dart';
import 'address_adapter.dart';

abstract final class LocalStorage {
  static Future<Box<Address>> open() async {
    // hive_flutter resolve o diretório privado usando path e path_provider.
    await Hive.initFlutter('fast_delivery');
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AddressAdapter());
    return Hive.openBox<Address>('address_history_v1');
  }
}
