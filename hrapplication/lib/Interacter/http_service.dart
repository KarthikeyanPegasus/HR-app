import 'dart:developer';

import 'package:dio/dio.dart';

class http_service {
  late Dio _dio;
  late Response response;

  http_service() {
    _dio = Dio(BaseOptions(
      baseUrl: "https://questionshemeshanna.herokuapp.com/",
    ));
  }
  Future<Response> getResponse(String endpoint, data) async {
    response = await _dio.post(endpoint, data: data);
    if (response.statusCode == 200) {
      log("!!!!!!!!!!!!!!!!!!!!Success");
    } else {
      log("!!!!!!!!!!!!!!!!!!!!!${response.statusCode}");
    }
    return response;
  }
}
