import 'package:dio/dio.dart';

Dio createDio() => Dio(
  BaseOptions(
    baseUrl: 'https://viacep.com.br/ws/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
    responseType: ResponseType.json,
  ),
);
