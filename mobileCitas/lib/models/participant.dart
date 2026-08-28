import 'user.dart';

class Participant {
  final int id;
  final int userId;
  final int eventId;
  final User? user;
  final String? attendanceStatus;

  const Participant({
    required this.id,
    required this.userId,
    required this.eventId,
    this.user,
    this.attendanceStatus,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    final userJson = json['Usuario'] ?? json['usuario'];
    final asistenciaJson = json['Asistencia'] ?? json['asistencia'];

    return Participant(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['usuarioId'].toString()) ?? 0,
      eventId: int.tryParse(json['eventoId'].toString()) ?? 0,
      user: userJson != null
          ? User.fromJson(userJson as Map<String, dynamic>)
          : null,
      attendanceStatus: asistenciaJson != null
          ? (asistenciaJson['estado'] ?? asistenciaJson['status'])?.toString()
          : null,
    );
  }
}