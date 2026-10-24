import 'package:flutter_test/flutter_test.dart';
import 'package:fast_delivery/src/modules/home/model/address.dart';
import 'package:fast_delivery/src/modules/home/service/address_service.dart';
import 'package:fast_delivery/src/modules/home/service/address_validation.dart';
import 'package:fast_delivery/src/shared/components/app_exception.dart';
import 'helpers/fakes.dart';

void main() {
  late FakeRemote remote;
  late MemoryHistory history;
  late AddressService service;
  setUp(() {
    remote = FakeRemote();
    history = MemoryHistory();
    service = AddressService(
      remote,
      history,
      now: () => DateTime.utc(2026, 10, 21, 14),
    );
  });
  test('CEP formatado é normalizado antes da chamada remota', () async {
    expect(await service.findByCep(' 01001-000 '), sample);
    expect(remote.requestedCep, '01001000');
  });
  test('CEP inválido é rejeitado sem consultar a rede', () {
    for (final input in [
      '',
      '123',
      '123456789',
      '01001A000',
      'abcdefgh',
      '01001/000',
    ]) {
      expect(() => service.findByCep(input), throwsA(isA<AppException>()));
    }
    expect(remote.calls, 0);
  });
  test(
    'UF, cidade e rua são obrigatórios; cidade e rua exigem 3 caracteres',
    () {
      for (final input in [
        ['XX', 'São Paulo', 'Paulista'],
        ['', 'São Paulo', 'Paulista'],
        ['SP', '  ', 'Paulista'],
        ['SP', 'Oi', 'Paulista'],
        ['SP', 'São Paulo', 'ab'],
      ]) {
        expect(
          () => service.findByAddress(input[0], input[1], input[2]),
          throwsA(isA<AppException>()),
        );
      }
      expect(remote.calls, 0);
      expect(AddressValidation.states.length, 27);
    },
  );
  test(
    'endereço é normalizado e resultados não são salvos antes da seleção',
    () async {
      expect(
        await service.findByAddress('sp', ' São Paulo ', ' Paulista '),
        hasLength(2),
      );
      expect(remote.requestedAddress, ['SP', 'São Paulo', 'Paulista']);
      expect(history.entries, isEmpty);
      final saved = await service.record(second);
      expect(saved.consultedAt, DateTime.utc(2026, 10, 21, 14));
      expect(service.history().single.id, second.id);
    },
  );
  test(
    'serialização preserva campos e data; campos opcionais nulos são seguros',
    () {
      final value = sample.consulted(DateTime.utc(2026, 10, 21));
      expect(Address.fromJson(value.toJson()).toJson(), value.toJson());
      final sparse = Address.fromJson({
        'cep': '01001000',
        'bairro': null,
        'localidade': 'São Paulo',
        'uf': 'sp',
      });
      expect(sparse.neighborhood, '');
      expect(sparse.street, '');
      expect(sparse.state, 'SP');
      expect(sparse.consultedAt, isNull);
      expect(sparse.fullAddress, contains('São Paulo, SP, 01001-000, Brasil'));
    },
  );
}
