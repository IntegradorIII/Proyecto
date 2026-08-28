import 'package:dio/dio.dart';

import '/core/network/api_client.dart';
import '/models/user.dart';

const List<String> kRolesUsuario = [
  'Administrador',
  'Operador',
  'Miembro',
  'Invitado',
];


class UserService {
  final ApiClient _api = ApiClient();

  String _extractMensaje(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data["mensaje"] != null) {
      return data["mensaje"].toString();
    }
    return fallback;
  }

  /// GET /usuarios -> { usuarios: [...] }
  Future<List<User>> listarUsuarios() async {
    try {
      final response = await _api.dio.get("/api/usuarios");
      final data = response.data;

      final List<dynamic> raw =
          (data is Map && data["usuarios"] is List) ? data["usuarios"] : [];

      return raw.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al listar usuarios"));
    }
  }

  /// POST /usuarios -> { mensaje, usuario: {id, nombre, correo, rol} }
  Future<User> registrarUsuario({
    required String nombre,
    required String cedula,
    required String correo,
    required String password,
    required String rol,
  }) async {
    try {
      final response = await _api.dio.post(
        "/api/usuarios",
        data: {
          "nombre": nombre,
          "cedula": cedula,
          "correo": correo,
          "password": password,
          "rol": rol,
        },
      );

      return User.fromJson(response.data["usuario"]);
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al registrar usuario"));
    }
  }

  /// PUT /usuarios/:id -> { mensaje, usuario }
  Future<User> editarUsuario({
    required int id,
    required String nombre,
    required String cedula,
    required String correo,
    required String rol,
  }) async {
    try {
      final response = await _api.dio.put(
        "/api/usuarios/$id",
        data: {
          "nombre": nombre,
          "cedula": cedula,
          "correo": correo,
          "rol": rol,
        },
      );

      return User.fromJson(response.data["usuario"]);
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al editar usuario"));
    }
  }

  /// DELETE /usuarios/:id
  Future<void> eliminarUsuario(int id) async {
    try {
      await _api.dio.delete("/api/usuarios/$id");
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al eliminar usuario"));
    }
  }
}