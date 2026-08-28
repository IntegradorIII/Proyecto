import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../models/meeting.dart';
import '/models/participant.dart';
import '/models/attendance.dart';
import '/core/services/meeting_service.dart';
import '/core/services/attendance_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';


class AttendanceCheckinScreen extends StatefulWidget {
  final Meeting meeting;

  const AttendanceCheckinScreen({super.key, required this.meeting});

  @override
  State<AttendanceCheckinScreen> createState() =>
      _AttendanceCheckinScreenState();
}

class _AttendanceCheckinScreenState extends State<AttendanceCheckinScreen> {
  final MeetingService _meetingService = MeetingService();
  final AttendanceService _attendanceService = AttendanceService();

  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();

  List<Participant> _participantes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // usuarioId -> mensaje ("presente"/"tardio"/error) para feedback inline.
  final Map<int, String> _resultadoPorUsuario = {};
  bool _isRegistrandoInvitado = false;

  bool get _esAbierta => widget.meeting.tipoReunion == TipoReunion.abierta;

  @override
  void initState() {
    super.initState();
    _cargarParticipantes();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  Future<void> _cargarParticipantes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _meetingService.listarParticipantes(widget.meeting.id),
        _attendanceService.report(widget.meeting.id).catchError((_) => null),
      ]);
      
      final participantes = results[0] as List<Participant>;
      final reporte = results[1] as AttendanceReport?;

      if (!mounted) return;
      setState(() {
        _participantes = participantes;
        _isLoading = false;

        _resultadoPorUsuario.clear();

        // 1. Cruce con el reporte (fuente de la verdad principal)
        if (reporte != null) {
          for (var item in reporte.detail) {
            if (item.status == AttendanceStatus.present || item.status == AttendanceStatus.late) {
               final matches = _participantes.where((p) => p.user?.iden == item.identification).toList();
               if (matches.isNotEmpty) {
                 final estadoStr = item.status == AttendanceStatus.late ? "tardio" : "presente";
                 _resultadoPorUsuario[matches.first.userId] = "Registrado: $estadoStr";
               }
            }
          }
        }

        // 2. Mapeo fallback por si el reporte falló
        for (var p in participantes) {
          if (!_resultadoPorUsuario.containsKey(p.userId)) {
            if (p.attendanceStatus != null && p.attendanceStatus!.isNotEmpty) {
              _resultadoPorUsuario[p.userId] = "Registrado: ${p.attendanceStatus}";
            } else if (p.attendanceStatus?.toLowerCase() == 'presente' || 
                       p.attendanceStatus?.toLowerCase() == 'tardio') {
              _resultadoPorUsuario[p.userId] = "Registrado: ${p.attendanceStatus}";
            }
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _marcarAsistenciaMiembro(Participant p) async {
    setState(() => _resultadoPorUsuario.remove(p.userId));

    try {
      final attendance = await _attendanceService.checkInManual(
        eventId: widget.meeting.id,
        userId: p.userId,
      );
      if (!mounted) return;
      setState(() {
        _resultadoPorUsuario[p.userId] =
            "Registrado: ${attendance.estado}";
      });
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceFirst("Exception: ", "");
      setState(() {
        final errorLower = errorMsg.toLowerCase();
        if (errorLower.contains("ya tiene asistencia") ||
            errorLower.contains("ya está") ||
            errorLower.contains("ya existe") ||
            errorLower.contains("registrada")) {
          // El backend rechazó porque ya está registrado.
          // Actualizamos el estado visual localmente al badge verde.
          _resultadoPorUsuario[p.userId] = "Registrado: presente";
        } else {
          _resultadoPorUsuario[p.userId] = errorMsg;
        }
      });
    }
  }

  Future<void> _registrarInvitado() async {
    final nombre = _nombreController.text.trim();
    final cedula = _cedulaController.text.trim();

    if (nombre.isEmpty || cedula.isEmpty) {
      setState(() => _errorMessage = "Complete nombre y cédula");
      return;
    }

    setState(() {
      _isRegistrandoInvitado = true;
      _errorMessage = null;
    });

    try {
      final attendance = await _attendanceService.checkInManual(
        eventId: widget.meeting.id,
        name: nombre,
        identification: cedula,
      );

      _nombreController.clear();
      _cedulaController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$nombre registrado como ${attendance.estado}"),
        ),
      );

      // El invitado queda asociado como Participante; refrescamos la lista.
      await _cargarParticipantes();

      setState(() => _isRegistrandoInvitado = false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isRegistrandoInvitado = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asistencia · ${widget.meeting.title}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarParticipantes,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    _esAbierta
                        ? "Reunión abierta: se aceptan invitados."
                        : "Reunión solo para miembros convocados.",
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    "Participantes convocados (${_participantes.length})",
                    style: AppTextStyles.heading,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.body.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  if (_participantes.isEmpty)
                    Text(
                      "Todavía no hay participantes convocados.",
                      style: AppTextStyles.body,
                    )
                  else
                    ..._participantes.map((p) {
                      final resultado = _resultadoPorUsuario[p.userId];
                      final isRegistrado = resultado != null && resultado.startsWith("Registrado");
                      
                      Widget trailingWidget;
                      if (isRegistrado) {
                        final estadoLower = resultado.toLowerCase();
                        IconData iconData = Icons.check_circle;
                        Color badgeColor = Colors.green;
                        
                        if (estadoLower.contains('tardio') || estadoLower.contains('tardío')) {
                          iconData = Icons.schedule;
                          badgeColor = Colors.orange;
                        } else if (estadoLower.contains('ausente')) {
                          iconData = Icons.cancel;
                          badgeColor = Colors.red;
                        }

                        trailingWidget = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(25), // 0.1 opacity
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: badgeColor.withAlpha(128)), // 0.5 opacity
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(iconData, size: 16, color: badgeColor),
                              const SizedBox(width: 4),
                              Text(
                                estadoLower.contains('tardio') 
                                    ? "Tardío" 
                                    : estadoLower.contains('ausente') 
                                        ? "Ausente" 
                                        : "Presente",
                                style: AppTextStyles.body.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        trailingWidget = TextButton(
                          onPressed: () => _marcarAsistenciaMiembro(p),
                          child: const Text("Marcar"),
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          title: Text(p.user?.name ?? "Usuario ${p.userId}"),
                          subtitle: Text(
                            isRegistrado 
                                ? "${p.user?.iden ?? ''} · ${p.user?.role ?? ''}"
                                : resultado ?? "${p.user?.iden ?? ''} · ${p.user?.role ?? ''}",
                            style: (resultado != null && !isRegistrado)
                                ? AppTextStyles.body.copyWith(color: Colors.red)
                                : null,
                          ),
                          trailing: trailingWidget,
                        ),
                      );
                    }),

                  if (_esAbierta) ...[
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      "Registrar invitado",
                      style: AppTextStyles.heading,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    AppTextField(
                      controller: _nombreController,
                      label: "Nombre completo",
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    AppTextField(
                      controller: _cedulaController,
                      label: "Cédula",
                    ),

                    const SizedBox(height: AppSpacing.md),

                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: _isRegistrandoInvitado
                            ? "Registrando..."
                            : "Registrar asistencia de invitado",
                        onPressed: _isRegistrandoInvitado
                            ? null
                            : _registrarInvitado,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
