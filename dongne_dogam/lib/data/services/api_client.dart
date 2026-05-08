import 'package:dio/dio.dart';

class ApiClient {
  static const _baseUrl = 'http://localhost:8000';

  final Dio dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ));
}
