import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:fast_delivery/src/modules/home/controller/home_controller.dart';
import 'package:fast_delivery/src/modules/home/model/address.dart';
import 'package:fast_delivery/src/modules/home/service/address_service.dart';
import 'package:fast_delivery/src/modules/home/service/navigation_service.dart';
import 'package:fast_delivery/src/shared/components/app_exception.dart';
import 'package:fast_delivery/src/modules/history/controller/history_controller.dart';
import 'helpers/fakes.dart';

void main() {
  late FakeRemote remote;
  late MemoryHistory history;
  late AddressService service;
  late HomeController controller;
  setUp(() {
    remote = FakeRemote();
    history = MemoryHistory();
    service = AddressService(remote, history);
    controller = HomeController(
      service,
      NavigationService(FakeGeocoder(), FakeMaps()),
    );
  });
  test(
    'consulta por CEP atualiza resultado, última consulta e recentes',
    () async {
      await controller.searchByCep('01001000');
      expect(controller.current!.id, sample.id);
      expect(controller.last!.id, sample.id);
      expect(controller.recent, hasLength(1));
      expect(controller.loading, isFalse);
      expect(controller.error, isNull);
    },
  );
  test('consulta por endereço só persiste o item selecionado', () async {
    await controller.searchByAddress('SP', 'São Paulo', 'Paulista');
    expect(controller.results, hasLength(2));
    expect(history.entries, isEmpty);
    await controller.selectResult(second);
    expect(history.entries.keys, [second.id]);
    expect(controller.last!.id, second.id);
    expect(controller.results, isEmpty);
  });
  test('loading é observável e impede consultas simultâneas', () async {
    final response = Completer<Address?>();
    remote.cepResponse = () => response.future;
    final states = <bool>[];
    final dispose = reaction<bool>((_) => controller.loading, states.add);
    final pending = controller.searchByCep('01001000');
    expect(controller.loading, isTrue);
    await controller.searchByCep('01310100');
    expect(remote.calls, 1);
    response.complete(sample);
    await pending;
    expect(states, [true, false]);
    dispose();
  });
  test(
    'erro dispara reação e loading sempre termina; consulta seguinte funciona',
    () async {
      final errors = <String?>[];
      final dispose = reaction<String?>((_) => controller.error, errors.add);
      remote.cepResponse = () async => throw const AppException('Sem conexão.');
      await controller.searchByCep('01001000');
      expect(controller.error, 'Sem conexão.');
      expect(controller.loading, isFalse);
      expect(controller.current, isNull);
      expect(errors, contains('Sem conexão.'));
      remote.cepResponse = null;
      await controller.searchByCep('01001000');
      expect(controller.error, isNull);
      expect(controller.current, isNotNull);
      dispose();
    },
  );
  test('CEP inexistente e lista vazia geram estado sem resultados', () async {
    remote.cepResponse = () async => null;
    await controller.searchByCep('99999999');
    expect(controller.notFound, isTrue);
    remote.matches = [];
    await controller.searchByAddress('SP', 'São Paulo', 'Inexistente');
    expect(controller.notFound, isTrue);
    expect(controller.error, isNull);
  });
  test(
    'falha de persistência mantém endereço encontrado e não inventa histórico',
    () async {
      history.failSave = true;
      await controller.searchByCep('01001000');
      expect(controller.current!.id, sample.id);
      expect(controller.last, isNull);
      expect(controller.error, isNotNull);
      expect(controller.loading, isFalse);
    },
  );
  test(
    'visualizar registro local não muda data nem dispara consulta remota',
    () async {
      await controller.searchByCep('01001000');
      final at = controller.last!.consultedAt;
      controller.openLocal(controller.last!);
      expect(controller.isLocal, isTrue);
      expect(controller.last!.consultedAt, at);
      expect(remote.calls, 1);
    },
  );
  test('controller do histórico recupera novas consultas locais', () async {
    final controller = HistoryController(service)..load();
    expect(controller.entries, isEmpty);
    await service.record(sample);
    controller.load();
    expect(controller.entries.single.id, sample.id);
    history.failRead = true;
    controller.load();
    expect(controller.error, isNotNull);
  });
}
