import 'dart:io';
import 'package:fast_delivery/src/http/dio_client.dart';
import 'package:fast_delivery/src/modules/home/repositories/viacep_repository.dart';

/// Smoke test opt-in: três requisições reais, fora da suíte determinística.
Future<void> main() async {
  final dio = createDio();
  final repository = ViaCepRepository(dio);
  try {
    final cep = await repository.findByCep('01001000');
    if (cep == null || cep.city != 'São Paulo') {
      throw StateError('CEP conhecido não retornou o município esperado.');
    }
    stdout.writeln(
      'CEP: ${cep.formattedCep} | ${cep.title} | ${cep.cityState}',
    );
    final missing = await repository.findByCep('99999999');
    if (missing != null) throw StateError('CEP inexistente retornou endereço.');
    stdout.writeln('CEP inexistente: tratado corretamente.');
    final found = await repository.findByAddress('SP', 'São Paulo', 'Paulista');
    if (found.isEmpty) {
      throw StateError('Pesquisa por endereço sem resultados.');
    }
    stdout.writeln('Endereço: ${found.length} resultado(s) do ViaCEP.');
  } catch (error) {
    stderr.writeln('Verificação remota falhou: $error');
    exitCode = 1;
  } finally {
    dio.close(force: true);
  }
}
