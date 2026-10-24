import 'package:flutter_test/flutter_test.dart';
import 'package:fast_delivery/src/modules/home/controller/home_controller.dart';
import 'package:fast_delivery/src/modules/home/service/address_service.dart';
import 'package:fast_delivery/src/modules/home/service/navigation_service.dart';
import 'package:fast_delivery/src/shared/components/app_exception.dart';
import 'helpers/fakes.dart';

void main() {
  late FakeGeocoder geocoder;
  late FakeMaps maps;
  late NavigationService service;
  setUp(() {
    geocoder = FakeGeocoder();
    maps = FakeMaps();
    service = NavigationService(geocoder, maps);
  });
  test(
    'rota geocodifica o endereço selecionado e abre o aplicativo escolhido',
    () async {
      final options = await service.prepare(second);
      expect(geocoder.query, second.fullAddress);
      expect(maps.destination!.latitude, -23.55);
      expect(options.single.name, 'Mapa de teste');
      await service.open(options.single);
      expect(maps.opened, 1);
    },
  );
  test('rota da última consulta usa os dados efetivamente salvos', () async {
    final controller = HomeController(
      AddressService(FakeRemote(), MemoryHistory()),
      service,
    );
    await controller.searchByCep('01001000');
    await controller.prepareRoute(controller.last!);
    expect(geocoder.query, sample.fullAddress);
    expect(controller.routeLoading, isFalse);
  });
  test('nenhum mapa instalado resulta em mensagem específica', () async {
    maps.empty = true;
    await expectLater(
      service.prepare(sample),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'mensagem',
          contains('Nenhum mapa'),
        ),
      ),
    );
  });
  test(
    'geocoding sem resultado e coordenadas inválidas são rejeitados',
    () async {
      geocoder.locations = [];
      await expectLater(service.prepare(sample), throwsA(isA<AppException>()));
      geocoder.locations = [const Coordinates(999, 0)];
      await expectLater(service.prepare(sample), throwsA(isA<AppException>()));
    },
  );
  test('falhas no geocoding e abertura de mapa recebem tratamento', () async {
    geocoder.fail = true;
    await expectLater(service.prepare(sample), throwsA(isA<AppException>()));
    geocoder.fail = false;
    maps.failOpen = true;
    final options = await service.prepare(sample);
    await expectLater(
      service.open(options.single),
      throwsA(isA<AppException>()),
    );
  });
}
