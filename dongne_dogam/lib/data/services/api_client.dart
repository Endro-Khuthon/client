import 'dart:io';

import 'package:dio/dio.dart';

class ApiClient {
  static final _baseUrl =
      Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000';

  final Dio dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ));
}
