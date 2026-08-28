import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../models/meeting.dart';
import '/models/participant.dart';
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
      final participantes =
          await _meetingService.listarParticipantes(widget.meeting.id);
      setState(() {
        _participantes = participantes;
        _isLoading = false;
      });
    } catch (e) {
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
      setState(() {
        _resultadoPorUsuario[p.userId] =
            "Registrado: ${attendance.status.name}";
      });
    } catch (e) {
      setState(() {
        _resultadoPorUsuario[p.userId] =
            e.toString().replaceFirst("Exception: ", "");
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
          content: Text("$nombre registrado como ${attendance.status.name}"),
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          title: Text(p.user?.name ?? "Usuario ${p.userId}"),
                          subtitle: Text(
                            resultado ??
                                "${p.user?.iden ?? ''} · ${p.user?.role ?? ''}",
                            style: resultado != null
                                ? AppTextStyles.body.copyWith(
                                    color: resultado.startsWith("Registrado")
                                        ? Colors.green
                                        : Colors.red,
                                  )
                                : null,
                          ),
                          trailing: TextButton(
                            onPressed: () => _marcarAsistenciaMiembro(p),
                            child: const Text("Marcar"),
                          ),
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
