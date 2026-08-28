import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '/models/login_response.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<LoginResponse> login({
    required String correo,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        "/api/auth/login",
        data: {
          "correo": correo,
          "password": password,
        },
      );
      print(response.data);
      print(response.data.runtimeType);

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["mensaje"] ?? "Error al iniciar sesión",
      );
    }
  }
}