import 'package:dio/dio.dart';

import '../storage/session_manager.dart';
import 'api_constants.dart';
import '../routes/app_routes.dart';
import '../../main.dart'; // Para acceder a navigatorKey

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Lectura síncrona del token desde el caché
          final token = SessionManager.token;

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Si el servidor responde con 401 (Token expirado o inválido)
          if (error.response?.statusCode == 401) {
            // Limpiamos la sesión actual
            await SessionManager.clearSession();
            
            // Redirigimos al Login usando la clave global, cerrando todas las pantallas previas
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          }
          
          handler.next(error);
        },
      ),
    );
  }
}