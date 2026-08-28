import 'package:dio/dio.dart';

import '../storage/session_manager.dart';
import 'api_constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          final token = await SessionManager.getToken();

          if (token != null) {
            options.headers["Authorization"] =
                "Bearer $token";
          }

          handler.next(options);
        },

        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }
}