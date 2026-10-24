import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fast_delivery/src/app.dart';
import 'package:fast_delivery/src/app_dependencies.dart';
import 'package:fast_delivery/src/modules/home/model/address.dart';
import 'package:fast_delivery/src/modules/home/service/address_service.dart';
import 'package:fast_delivery/src/modules/home/service/navigation_service.dart';
import 'package:fast_delivery/src/shared/components/app_exception.dart';
import 'helpers/fakes.dart';

void main() {
  late FakeRemote remote;
  late MemoryHistory history;
  late FakeMaps maps;
  late AppDependencies dependencies;
  setUp(() {
    remote = FakeRemote();
    history = MemoryHistory();
    maps = FakeMaps();
    dependencies = AppDependencies(
      AddressService(remote, history),
      NavigationService(FakeGeocoder(), maps),
    );
  });
  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(FastDeliveryApp(dependencies: dependencies));
    await tester.pumpAndSettle();
  }

  testWidgets('splash navega automaticamente e não fica na pilha', (
    tester,
  ) async {
    await tester.pumpWidget(FastDeliveryApp(dependencies: dependencies));
    expect(find.text('O próximo destino começa aqui.'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Consultar endereço'), findsOneWidget);
    expect(find.text('O próximo destino começa aqui.'), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });
  testWidgets('formulário rejeita CEP inválido sem rede', (tester) async {
    await open(tester);
    await tester.enterText(find.byKey(const ValueKey('cep-field')), '123');
    await tester.tap(find.text('Consultar endereço'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um CEP com 8 dígitos.'), findsOneWidget);
    expect(remote.calls, 0);
  });
  testWidgets(
    'loading aparece, Observer mostra resultado e histórico carrega automaticamente',
    (tester) async {
      final response = Completer<Address?>();
      remote.cepResponse = () => response.future;
      await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('cep-field')),
        '01001000',
      );
      await tester.tap(find.text('Consultar endereço'));
      await tester.pump();
      expect(find.text('Consultando…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      response.complete(sample);
      await tester.pumpAndSettle();
      expect(find.text('Endereço encontrado'), findsOneWidget);
      expect(history.entries, hasLength(1));
      await tester.tap(find.byTooltip('Histórico'));
      await tester.pumpAndSettle();
      expect(find.text('Praça da Sé'), findsOneWidget);
      expect(find.text('01001-000'), findsOneWidget);
      await tester.tap(find.text('Praça da Sé'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(Chip, 'Salvo neste dispositivo'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('formulário por endereço valida os três campos', (tester) async {
    await open(tester, size: const Size(390, 1000));
    await tester.tap(find.text('Por endereço'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Consultar endereço'));
    await tester.tap(find.text('Consultar endereço'));
    await tester.pumpAndSettle();
    expect(find.text('Selecione uma UF válida.'), findsOneWidget);
    expect(
      find.text('A cidade deve ter pelo menos 3 caracteres.'),
      findsOneWidget,
    );
    expect(
      find.text('O logradouro deve ter pelo menos 3 caracteres.'),
      findsOneWidget,
    );
    expect(remote.calls, 0);
  });
  testWidgets(
    'consulta por endereço permite escolher e persistir um resultado',
    (tester) async {
      await open(tester, size: const Size(430, 1200));
      await tester.tap(find.text('Por endereço'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('state-field')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('SP'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('city-field')),
        'São Paulo',
      );
      await tester.enterText(
        find.byKey(const ValueKey('street-field')),
        'Paulista',
      );
      await tester.ensureVisible(find.text('Consultar endereço'));
      await tester.tap(find.text('Consultar endereço'));
      await tester.pumpAndSettle();
      expect(history.entries, isEmpty);
      await tester.scrollUntilVisible(
        find.text('Avenida Paulista'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Avenida Paulista'));
      await tester.pumpAndSettle();
      expect(history.entries.keys, [second.id]);
      expect(remote.requestedAddress, ['SP', 'São Paulo', 'Paulista']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('erro remoto gera mensagem em português e encerra loading', (
    tester,
  ) async {
    remote.cepResponse = () async =>
        throw const AppException('Sem conexão com o ViaCEP.');
    await open(tester);
    await tester.enterText(find.byKey(const ValueKey('cep-field')), '01001000');
    await tester.tap(find.text('Consultar endereço'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Sem conexão com o ViaCEP.'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('histórico vazio permite voltar à Home', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Seu histórico começa aqui'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Consultar endereço'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('rota oferece mapa compatível e abre a opção escolhida', (
    tester,
  ) async {
    await history.save(sample.consulted(DateTime.utc(2026, 10, 21)));
    await open(tester, size: const Size(430, 1100));
    await tester.ensureVisible(find.text('Traçar rota').first);
    await tester.tap(find.text('Traçar rota').first);
    await tester.pumpAndSettle();
    expect(find.text('Abrir rota com'), findsOneWidget);
    await tester.tap(find.text('Mapa de teste'));
    await tester.pumpAndSettle();
    expect(maps.opened, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('tela estreita com fonte ampliada mantém formulário acessível', (
    tester,
  ) async {
    await open(tester, size: const Size(320, 640), textScale: 1.6);
    await tester.scrollUntilVisible(find.text('Por endereço'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Por endereço'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Consultar endereço'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('city-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
