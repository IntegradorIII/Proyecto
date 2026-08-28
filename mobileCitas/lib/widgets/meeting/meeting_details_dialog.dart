import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/storage/session_manager.dart';
import '../../models/meeting.dart';
import '/core/services/participant_service.dart';

import '../../screens/meetings/meeting_participants_screen.dart';
import '../../screens/attendance/attendance_checkin_screen.dart';

class MeetingDetailsDialog extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailsDialog({
    super.key,
    required this.meeting,
  });

  @override
  State<MeetingDetailsDialog> createState() => _MeetingDetailsDialogState();
}

class _MeetingDetailsDialogState extends State<MeetingDetailsDialog> {
  final ParticipantService _participantService = ParticipantService();

  int? _totalParticipantes;
  bool _isLoadingCount = true;
  bool _puedeGestionar = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _isLoadingCount = true;
      _errorMessage = null;
    });

    try {
      final participantes =
          await _participantService.listarParticipantes(widget.meeting.id);
      final puedeGestionar = SessionManager.puedeGestionarEventos;

      if (!mounted) return;
      setState(() {
        _totalParticipantes = participantes.length;
        _puedeGestionar = puedeGestionar;
        _isLoadingCount = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCount = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _irAParticipantes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeetingParticipantsScreen(
          meetingId: widget.meeting.id,
          meetingTitle: widget.meeting.title,
        ),
      ),
    );
    // Puede haber cambiado la cantidad de participantes al volver.
    _cargar();
  }

  void _irAAsistencia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceCheckinScreen(meeting: widget.meeting),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meeting = widget.meeting;

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meeting.title,
                        style: AppTextStyles.pageTitle,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                if (isMobile) ...[
                  // En móvil, el QR arriba y la información abajo
                  Center(child: _MeetingQrCode(meeting: meeting)),
                  const SizedBox(height: AppSpacing.lg),
                  _MeetingInformation(meeting: meeting),
                ] else ...[
                  // En escritorio, usamos Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _MeetingInformation(
                          meeting: meeting,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _MeetingQrCode(meeting: meeting),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                const Divider(),

                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Text(
                      "Participantes",
                      style: AppTextStyles.heading,
                    ),

                    const Spacer(),

                    if (_isLoadingCount)
                      Text("cargando...", style: AppTextStyles.body)
                    else if (_errorMessage != null)
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.body.copyWith(color: Colors.red),
                          textAlign: TextAlign.end,
                        ),
                      )
                    else
                      Text(
                        "${_totalParticipantes ?? 0} participantes",
                        style: AppTextStyles.body,
                      ),
                  ],
                ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _puedeGestionar ? _irAParticipantes : null,
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text("Añadir participantes"),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _puedeGestionar ? _irAAsistencia : null,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text("Tomar asistencia"),
                    ),
                  ),
                ],
              ),

              if (!_puedeGestionar) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Gestionar participantes y asistencia requiere rol "
                  "Operador o Administrador.",
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _MeetingInformation extends StatelessWidget {
  final Meeting meeting;

  const _MeetingInformation({
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InformationRow(
          icon: Icons.calendar_today_outlined,
          text: _formatDate(meeting.dateTime),
        ),

        const SizedBox(height: AppSpacing.md),

        _InformationRow(
          icon: Icons.location_on_outlined,
          text: meeting.location,
        ),

        const SizedBox(height: AppSpacing.md),

        _InformationRow(
          icon: Icons.hourglass_bottom_outlined,
          text: "Tolerancia: ${meeting.toleranceMinutes} min",
        ),

        const SizedBox(height: AppSpacing.md),

        _InformationRow(
          icon: meeting.tipoReunion == TipoReunion.abierta
              ? Icons.lock_open_outlined
              : Icons.lock_outline,
          text: meeting.tipoReunion == TipoReunion.abierta
              ? "Reunión abierta (acepta invitados)"
              : "Solo miembros convocados",
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$day/$month/${date.year}   $hour:$minute";
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InformationRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}

class _MeetingQrCode extends StatelessWidget {
  final Meeting meeting;

  const _MeetingQrCode({required this.meeting});

  /// El backend genera el QR real en crearEvento (QRCode.toDataURL) y lo
  Uint8List? _decodeQr() {
    final raw = meeting.codigoQr;
    if (raw == null || raw.isEmpty) return null;

    final base64Part = raw.contains(',') ? raw.split(',').last : raw;
    try {
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeQr();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: bytes != null
          ? Image.memory(bytes, width: 200, height: 200)
          : QrImageView(
              data: "evento-${meeting.id}",
              size: 200,
            ),
    );
  }
}