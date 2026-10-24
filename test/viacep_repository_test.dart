import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fast_delivery/src/http/dio_client.dart';
import 'package:fast_delivery/src/modules/home/repositories/viacep_repository.dart';
import 'package:fast_delivery/src/shared/components/app_exception.dart';
import 'helpers/fakes.dart';

class ResponseAdapter implements HttpClientAdapter {
  dynamic data = sample.toJson();
  String? raw;
  int status = 200;
  DioExceptionType? failure;
  Uri? uri;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    uri = options.uri;
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }
    return ResponseBody.fromString(
      raw ?? jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late ResponseAdapter adapter;
  late ViaCepRepository repo;
  setUp(() {
    dio = createDio();
    adapter = ResponseAdapter();
    dio.httpClientAdapter = adapter;
    repo = ViaCepRepository(dio);
  });
  tearDown(() => dio.close(force: true));
  test('CEP válido usa o endpoint correto e desserializa JSON', () async {
    final address = await repo.findByCep('01001000');
    expect(address!.street, 'Praça da Sé');
    expect(adapter.uri.toString(), 'https://viacep.com.br/ws/01001000/json/');
  });
  test(
    'CEP inexistente trata erro booleano e string enviados pelo ViaCEP',
    () async {
      for (final error in [true, 'true']) {
        adapter.data = {'erro': error};
        expect(await repo.findByCep('99999999'), isNull);
      }
    },
  );
  test(
    'pesquisa por endereço codifica espaços, acentos, barra e interrogação',
    () async {
      adapter.data = [sample.toJson(), second.toJson()];
      final found = await repo.findByAddress('SP', 'São Paulo', 'Rua A/B?');
      expect(found, hasLength(2));
      expect(adapter.uri!.pathSegments, [
        'ws',
        'SP',
        'São Paulo',
        'Rua A/B?',
        'json',
        '',
      ]);
      expect(adapter.uri!.query, isEmpty);
    },
  );
  test('lista vazia é um resultado sem correspondências', () async {
    adapter.data = [];
    expect(await repo.findByAddress('SP', 'São Paulo', 'Nada'), isEmpty);
  });
  test('respostas inválidas e incompletas são rejeitadas', () async {
    for (final data in [
      null,
      [],
      {'cep': '123'},
      {'cep': '01001000'},
    ]) {
      adapter.data = data;
      await expectLater(
        repo.findByCep('01001000'),
        throwsA(isA<AppException>()),
      );
    }
    adapter.raw = 'isto não é JSON';
    await expectLater(repo.findByCep('01001000'), throwsA(isA<AppException>()));
  });
  for (final type in [
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  ]) {
    test('$type informa timeout', () async {
      adapter.failure = type;
      await expectLater(
        repo.findByCep('01001000'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'mensagem',
            contains('demorou'),
          ),
        ),
      );
    });
  }
  test('falha de conexão apresenta mensagem específica', () async {
    adapter.failure = DioExceptionType.connectionError;
    await expectLater(
      repo.findByCep('01001000'),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'mensagem',
          contains('conexão'),
        ),
      ),
    );
  });
  test('HTTP 503 apresenta status e permite nova tentativa', () async {
    adapter.status = 503;
    await expectLater(
      repo.findByCep('01001000'),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'mensagem',
          contains('503'),
        ),
      ),
    );
  });
}
