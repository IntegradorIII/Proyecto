import 'package:dio/dio.dart';

import '/core/network/api_client.dart';
import '/models/participant.dart';

class ParticipantService {
  final ApiClient _api = ApiClient();

  String _extractMensaje(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data["mensaje"] != null) {
      return data["mensaje"].toString();
    }
    return fallback;
  }

  /// POST /eventos/:id/participantes -> asocia un Usuario YA EXISTENTE
  /// (por su id) a un evento existente. Requiere rol Operador o
  /// Administrador (soloOperador en el backend). El backend valida
  /// duplicados (400 si "El participante ya está asociado a este evento").
  Future<Participant> asociarParticipante({
    required int eventoId,
    required int usuarioId,
  }) async {
    try {
      final response = await _api.dio.post(
        "/api/eventos/$eventoId/participantes",
        data: {"usuarioId": usuarioId},
      );

      return Participant.fromJson(response.data["participante"]);
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al asociar participante"));
    }
  }

  /// GET /eventos/:id/participantes -> Participantes de un evento,
  /// cada uno con su Usuario anidado. Cualquier usuario autenticado
  /// puede verlos (solo verificarToken, sin restricción de rol).
  Future<List<Participant>> listarParticipantes(int eventoId) async {
    try {
      final response = await _api.dio.get("/api/eventos/$eventoId/participantes");
      final data = response.data;

      final List<dynamic> raw =
          (data is Map && data["participantes"] is List)
              ? data["participantes"]
              : (data is List ? data : []);

      return raw.map((json) => Participant.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_extractMensaje(e, "Error al obtener participantes"));
    }
  }
}