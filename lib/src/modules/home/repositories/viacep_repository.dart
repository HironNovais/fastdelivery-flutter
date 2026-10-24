import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../shared/components/app_exception.dart';
import '../model/address.dart';
import 'address_repository.dart';

class ViaCepRepository implements AddressRepository {
  ViaCepRepository(this._dio);
  final Dio _dio;
  Future<dynamic> _get(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      final data = response.data;
      return data is String ? jsonDecode(data) : data;
    } on DioException catch (error) {
      if (error.error is FormatException) {
        throw const AppException('O ViaCEP enviou uma resposta inválida.');
      }
      throw AppException(switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'A consulta demorou demais. Tente novamente.',
        DioExceptionType.connectionError =>
          'Sem conexão com o ViaCEP. Verifique sua internet.',
        DioExceptionType.badResponse =>
          'O ViaCEP está indisponível (HTTP ${error.response?.statusCode}). Tente novamente mais tarde.',
        DioExceptionType.badCertificate =>
          'Não foi possível estabelecer uma conexão segura com o ViaCEP.',
        _ => 'Não foi possível consultar o ViaCEP. Tente novamente.',
      });
    } on FormatException {
      throw const AppException('O ViaCEP enviou uma resposta inválida.');
    }
  }

  Address _parse(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const AppException('O ViaCEP enviou uma resposta inválida.');
    }
    final address = Address.fromJson(value);
    if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(address.cep) ||
        address.city.isEmpty ||
        !RegExp(r'^[A-Z]{2}$').hasMatch(address.state)) {
      throw const AppException('O ViaCEP enviou um endereço incompleto.');
    }
    return address;
  }

  @override
  Future<Address?> findByCep(String cep) async {
    final data = await _get('$cep/json/');
    if (data is Map && (data['erro'] == true || data['erro'] == 'true')) {
      return null;
    }
    return _parse(data);
  }

  @override
  Future<List<Address>> findByAddress(
    String state,
    String city,
    String street,
  ) async {
    final path = [state, city, street].map(Uri.encodeComponent).join('/');
    final data = await _get('$path/json/');
    if (data is! List) {
      throw const AppException('O ViaCEP enviou uma lista inválida.');
    }
    return data.map(_parse).toList(growable: false);
  }
}
