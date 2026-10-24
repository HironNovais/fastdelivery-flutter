import 'package:hive/hive.dart';
import '../../modules/home/model/address.dart';

/// Índices persistidos são estáveis: nunca reutilizar um índice removido.
class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 0;
  @override
  Address read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return Address(
      cep: fields[0] as String? ?? '',
      street: fields[1] as String? ?? '',
      complement: fields[2] as String? ?? '',
      neighborhood: fields[3] as String? ?? '',
      city: fields[4] as String? ?? '',
      state: fields[5] as String? ?? '',
      ibge: fields[6] as String? ?? '',
      consultedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.cep)
      ..writeByte(1)
      ..write(obj.street)
      ..writeByte(2)
      ..write(obj.complement)
      ..writeByte(3)
      ..write(obj.neighborhood)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.ibge)
      ..writeByte(7)
      ..write(obj.consultedAt);
  }
}
