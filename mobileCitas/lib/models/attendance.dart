enum AttendanceMethod { qr, manual }

enum AttendanceStatus { present, late, absent }

AttendanceMethod _methodFromString(String? value) {
  switch (value) {
    case 'qr':
      return AttendanceMethod.qr;
    case 'manual':
    default:
      return AttendanceMethod.manual;
  }
}

AttendanceStatus _statusFromString(String? value) {
  switch (value) {
    case 'presente':
      return AttendanceStatus.present;
    case 'tardio':
      return AttendanceStatus.late;
    case 'ausente':
    default:
      return AttendanceStatus.absent;
  }
}

class Attendance {
  final int id;
  final int usuarioId;
  final int eventoId;
  final String estado;
  final DateTime horaRegistro;
  final String? nombre;
  final String? cedula;

  const Attendance({
    required this.id,
    required this.usuarioId,
    required this.eventoId,
    required this.estado,
    required this.horaRegistro,
    this.nombre,
    this.cedula,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: int.tryParse(json['id'].toString()) ?? 0,
      usuarioId: int.tryParse(json['usuarioId'].toString()) ?? 0,
      eventoId: int.tryParse(json['eventoId'].toString()) ?? 0,
      estado: (json['estado'] ?? '').toString(),
      horaRegistro:
          DateTime.tryParse(json['horaRegistro']?.toString() ?? '') ??
              DateTime.now(),
      nombre: json['nombre']?.toString(),
      cedula: json['cedula']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'eventoId': eventoId,
      'estado': estado,
      'horaRegistro': horaRegistro.toIso8601String(),
      if (nombre != null) 'nombre': nombre,
      if (cedula != null) 'cedula': cedula,
    };
  }
}

/// Una fila del reporte de GET /eventos/:id/reporte
/// (no es un modelo de Sequelize, es el shape armado por el controller).
class AttendanceReportItem {
  final String name; // nombre
  final String identification; // cedula
  final String email; // correo
  final AttendanceStatus status; // estado
  final AttendanceMethod? method; // metodo
  final DateTime? checkInTime; // horaIngreso

  const AttendanceReportItem({
    required this.name,
    required this.identification,
    required this.email,
    required this.status,
    this.method,
    this.checkInTime,
  });

  factory AttendanceReportItem.fromJson(Map<String, dynamic> json) {
    return AttendanceReportItem(
      name: (json['nombre'] ?? '').toString(),
      identification: (json['cedula'] ?? '').toString(),
      email: (json['correo'] ?? '').toString(),
      status: _statusFromString(json['estado']?.toString()),
      method: json['metodo'] != null
          ? _methodFromString(json['metodo'].toString())
          : null,
      checkInTime: json['horaIngreso'] != null
          ? DateTime.tryParse(json['horaIngreso'].toString())
          : null,
    );
  }
}

class AttendanceReport {
  final String event; // evento
  final DateTime date; // fecha
  final int total;
  final int present; // presentes
  final int late; // tardios
  final int absent; // ausentes
  final List<AttendanceReportItem> detail; // detalle

  const AttendanceReport({
    required this.event,
    required this.date,
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.detail,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailRaw = json['detalle'] ?? [];

    return AttendanceReport(
      event: (json['evento'] ?? '').toString(),
      date: DateTime.tryParse(json['fecha']?.toString() ?? '') ??
          DateTime.now(),
      total: int.tryParse(json['total'].toString()) ?? 0,
      present: int.tryParse(json['presentes'].toString()) ?? 0,
      late: int.tryParse(json['tardios'].toString()) ?? 0,
      absent: int.tryParse(json['ausentes'].toString()) ?? 0,
      detail:
          detailRaw.map((e) => AttendanceReportItem.fromJson(e)).toList(),
    );
  }
}