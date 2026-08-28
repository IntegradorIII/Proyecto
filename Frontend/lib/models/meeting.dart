enum MeetingStatus {
  scheduled,
  inProgress,
  finished,
}

enum TipoReunion {
  soloMiembros,
  abierta,
}

TipoReunion _tipoReunionFromString(String? value) {
  return value == 'abierta' ? TipoReunion.abierta : TipoReunion.soloMiembros;
}

String tipoReunionToJson(TipoReunion tipo) {
  return tipo == TipoReunion.abierta ? 'abierta' : 'solo_miembros';
}

class Meeting {
  final int id;
  final String title; 
  final DateTime date;
  final String time; 
  final String location; 
  final int toleranceMinutes;
  final TipoReunion tipoReunion;
  final String? codigoQr; 
  final int participants;

  const Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.toleranceMinutes = 20,
    this.tipoReunion = TipoReunion.soloMiembros,
    this.codigoQr,
    this.participants = 0,
  });

  DateTime get dateTime {
    final parts = time.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }


  MeetingStatus get status {
    final now = DateTime.now();
    final dt = dateTime;
    if (dt.isAfter(now)) return MeetingStatus.scheduled;
    if (now.difference(dt) <= const Duration(hours: 2)) {
      return MeetingStatus.inProgress;
    }
    return MeetingStatus.finished;
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    final rawFecha = (json['fecha'] ?? '').toString();
    final parsedFecha = DateTime.tryParse(rawFecha) ?? DateTime.now();

    var rawHora = (json['hora'] ?? '00:00').toString();
    if (rawHora.length >= 5) rawHora = rawHora.substring(0, 5);

    return Meeting(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: (json['nombre'] ?? '').toString(),
      date: DateTime(parsedFecha.year, parsedFecha.month, parsedFecha.day),
      time: rawHora,
      location: (json['lugar'] ?? '').toString(),
      toleranceMinutes:
          int.tryParse(json['toleranciaMin']?.toString() ?? '') ?? 20,
      tipoReunion: _tipoReunionFromString(json['tipoReunion']?.toString()),
      codigoQr: json['codigoQr']?.toString(),
      participants: int.tryParse(json['participantes']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final fechaStr = "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    return {
      'nombre': title,
      'fecha': fechaStr,
      'hora': time,
      'lugar': location,
      'toleranciaMin': toleranceMinutes,
      'tipoReunion': tipoReunionToJson(tipoReunion),
    };
  }
}