import 'package:dio/dio.dart';

import '/core/network/api_client.dart';
import '/models/attendance.dart';


class AttendanceService {
  final ApiClient _api = ApiClient();

  static const String _base = "/api/asistencia";

  String _extractMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data["mensaje"] != null) {
      return data["mensaje"].toString();
    }
    return fallback;
  }

  Future<Attendance> checkInQR({
    required int userId,
    required int eventId,
  }) async {
    try {
      final response = await _api.dio.post(
        "$_base/check-in-qr",
        data: {
          "usuarioId": userId,
          "eventoId": eventId,
        },
      );

      return Attendance.fromJson(response.data["asistencia"]);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, "Error al registrar asistencia"));
    }
  }

  /// POST /check-in-invitado -> { eventId, name, identification }
  Future<Attendance> checkInGuest({
    required int eventId,
    required String name,
    required String identification,
  }) async {
    try {
      final response = await _api.dio.post(
        "$_base/check-in-invitado",
        data: {
          "eventoId": eventId,
          "nombre": name,
          "cedula": identification,
        },
      );

      return Attendance.fromJson(response.data["asistencia"]);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, "Error al registrar invitado"));
    }
  }

  /// POST /eventos/:id/asistencia-manual
  Future<Attendance> checkInManual({
    required int eventId,
    int? userId,
    String? name,
    String? identification,
  }) async {
    assert(
      (userId != null) ^ (name != null && identification != null),
      'Pasar usuarioId, o bien nombre y cedula (no ambos, no ninguno).',
    );

    try {
      final data = userId != null
          ? {"usuarioId": userId}
          : {"nombre": name, "cedula": identification};

      final response = await _api.dio.post(
        "$_base/eventos/$eventId/asistencia-manual",
        data: data,
      );

      return Attendance.fromJson(response.data["asistencia"]);
    } on DioException catch (e) {
      throw Exception(
        _extractMessage(e, "Error al registrar asistencia manual"),
      );
    }
  }

  /// GET /eventos/:id/reporte -> requires Administrator role.
  Future<AttendanceReport> report(int eventId) async {
    try {
      final response = await _api.dio.get("$_base/eventos/$eventId/reporte");
      return AttendanceReport.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, "Error al generar el reporte"));
    }
  }
}