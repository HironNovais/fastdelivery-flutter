import 'package:hive/hive.dart';
import '../../../shared/components/app_exception.dart';
import '../model/address.dart';
import 'history_repository.dart';

class HiveHistoryRepository implements HistoryRepository {
  HiveHistoryRepository(this._box);
  final Box<Address> _box;
  @override
  List<Address> readAll() {
    try {
      return _box.values.toList()..sort((a, b) {
        final oldest = DateTime.fromMillisecondsSinceEpoch(0);
        return (b.consultedAt ?? oldest).compareTo(a.consultedAt ?? oldest);
      });
    } catch (_) {
      throw const AppException('Não foi possível ler o histórico local.');
    }
  }

  @override
  Future<void> save(Address address) async {
    try {
      await _box.put(address.id, address);
      await _box.flush();
    } catch (_) {
      throw const AppException(
        'Endereço encontrado, mas não foi possível salvar o histórico neste dispositivo.',
      );
    }
  }
}
