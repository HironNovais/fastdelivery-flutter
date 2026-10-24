import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fast_delivery/src/modules/home/model/address.dart';
import 'package:fast_delivery/src/modules/home/repositories/hive_history_repository.dart';
import 'package:fast_delivery/src/shared/storage/address_adapter.dart';
import 'helpers/fakes.dart';

void main() {
  late Directory directory;
  late Box<Address> box;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fast_delivery_hive_');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AddressAdapter());
    box = await Hive.openBox<Address>('test_history');
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  test(
    'Hive real persiste dados e datas após fechar e reabrir o banco',
    () async {
      final repository = HiveHistoryRepository(box);
      final stored = sample.consulted(DateTime.utc(2026, 10, 21, 12));
      await repository.save(stored);
      await Hive.close();
      Hive.init(directory.path);
      box = await Hive.openBox<Address>('test_history');
      final loaded = HiveHistoryRepository(box).readAll();
      expect(loaded.single.toJson(), stored.toJson());
    },
  );
  test(
    'histórico ordena do mais recente e atualiza CEP repetido sem duplicar',
    () async {
      final repository = HiveHistoryRepository(box);
      await repository.save(sample.consulted(DateTime.utc(2026, 10, 21, 10)));
      await repository.save(second.consulted(DateTime.utc(2026, 10, 21, 11)));
      expect(repository.readAll().first.id, second.id);
      await repository.save(sample.consulted(DateTime.utc(2026, 10, 21, 12)));
      expect(box.length, 2);
      expect(repository.readAll().first.id, sample.id);
      await box.close();
      box = await Hive.openBox<Address>('test_history');
      expect(
        HiveHistoryRepository(box).readAll().first.consultedAt,
        DateTime.utc(2026, 10, 21, 12),
      );
    },
  );
}
