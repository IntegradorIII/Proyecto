import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '/core/network/api_client.dart';
import '/core/storage/session_manager.dart';
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

  Future<Attendance> checkInManual({
    required int eventId,
    int? userId,
    String? name,
    String? identification,
    String? email,
  }) async {
    assert(
      (userId != null) ^ (name != null && identification != null),
      'Pasar usuarioId, o bien nombre y cedula (no ambos, no ninguno).',
    );

    final String endpoint = "$_base/eventos/$eventId/asistencia-manual";
    final data = userId != null
        ? {"usuarioId": userId}
        : {
            "nombre": name,
            "cedula": identification,
            if (email != null && email.isNotEmpty) "correo": email,
          };

    try {
      debugPrint("[AttendanceService] POST $endpoint");
      debugPrint("[AttendanceService] Body: $data");

      final response = await _api.dio.post(
        endpoint,
        data: data,
      );

      debugPrint("[AttendanceService] SUCCESS: ${response.statusCode}");
      debugPrint("[AttendanceService] Response body: ${response.data}");

      return Attendance.fromJson(response.data["asistencia"]);
    } on DioException catch (e) {
      debugPrint("[AttendanceService] ERROR: ${e.response?.statusCode}");
      debugPrint("[AttendanceService] Response body: ${e.response?.data}");
      throw Exception(
        _extractMessage(e, "Error al registrar asistencia manual"),
      );
    }
  }

  Future<AttendanceReport> report(int eventId) async {
    try {
      final response = await _api.dio.get("$_base/eventos/$eventId/reporte");
      return AttendanceReport.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, "Error al generar el reporte"));
    }
  }

  Future<Attendance> registerAttendance(String qrData) async {
    try {
      int? eventId;

      try {
        final jsonMap = jsonDecode(qrData);
        if (jsonMap is Map && jsonMap['eventoId'] != null) {
          eventId = int.tryParse(jsonMap['eventoId'].toString());
        }
      } catch (_) {}

      if (eventId == null) {
        final regexReunion = RegExp(r'/reunion/(\d+)');
        final match = regexReunion.firstMatch(qrData);
        if (match != null && match.groupCount >= 1) {
          eventId = int.tryParse(match.group(1)!);
        }
      }

      if (eventId == null) {
        final regexParam = RegExp(r'reunionId=(\d+)');
        final match = regexParam.firstMatch(qrData);
        if (match != null && match.groupCount >= 1) {
          eventId = int.tryParse(match.group(1)!);
        }
      }

      if (eventId == null && qrData.startsWith('evento-')) {
        eventId = int.tryParse(qrData.split('-').last);
      }

      eventId ??= int.tryParse(qrData);

      if (eventId != null && eventId > 0) {
        final userIdStr = SessionManager.currentUser?['id']?.toString() ?? '0';
        final userId = int.tryParse(userIdStr) ?? 0;

        return await checkInQR(
          userId: userId,
          eventId: eventId,
        );
      }
      throw const FormatException("El código QR no contiene un ID de evento válido.");
    } catch (e) {
      if (e is DioException) {
        throw Exception(_extractMessage(e, "Error al registrar asistencia por QR"));
      }
      throw Exception("Formato de código QR no válido");
    }
  }
}