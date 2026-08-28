import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../models/meeting.dart';
import '/core/services/meeting_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

import 'meeting_participants_screen.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final MeetingService _meetingService = MeetingService();

  final _nombreController = TextEditingController();
  final _lugarController = TextEditingController();
  final _toleranciaController = TextEditingController(text: "20");

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  TipoReunion _tipoReunion = TipoReunion.soloMiembros;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _lugarController.dispose();
    _toleranciaController.dispose();
    super.dispose();
  }

  String get _fechaLabel {
    if (_fechaSeleccionada == null) return "Seleccionar fecha";
    final d = _fechaSeleccionada!;
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  String get _horaLabel {
    if (_horaSeleccionada == null) return "Seleccionar hora";
    final h = _horaSeleccionada!.hour.toString().padLeft(2, '0');
    final m = _horaSeleccionada!.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _horaSeleccionada = picked);
    }
  }

  Future<void> _crearReunion() async {
    final nombre = _nombreController.text.trim();
    final lugar = _lugarController.text.trim();
    final tolerancia = int.tryParse(_toleranciaController.text.trim()) ?? 20;

    if (nombre.isEmpty ||
        lugar.isEmpty ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      setState(() {
        _errorMessage = "Complete todos los campos obligatorios";
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final horaStr = "${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:"
          "${_horaSeleccionada!.minute.toString().padLeft(2, '0')}";

      final creada = await _meetingService.createMeeting(
        title: nombre,
        date: _fechaSeleccionada!,
        time: horaStr,
        location: lugar,
        toleranceMinutes: tolerancia,
        tipoReunion: _tipoReunion,
      );

      if (!mounted) return;

      // Va directo a asociar participantes a la reunión recién creada.
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingParticipantsScreen(
            meetingId: creada.id,
            meetingTitle: creada.title,
          ),
        ),
      );

      // Al volver de esa pantalla, avisa a MeetingsScreen que recargue.
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear reunión"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Crear reunión",
                    style: AppTextStyles.pageTitle,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Complete la información de la reunión.",
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    controller: _nombreController,
                    label: "Nombre de la reunión",
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    children: [
                      Expanded(
                        child: _PickerField(
                          label: "Fecha",
                          value: _fechaLabel,
                          icon: Icons.calendar_today_outlined,
                          onTap: _pickFecha,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _PickerField(
                          label: "Hora",
                          value: _horaLabel,
                          icon: Icons.access_time,
                          onTap: _pickHora,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _lugarController,
                    label: "Lugar",
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _toleranciaController,
                    label: "Tolerancia (minutos)",
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  DropdownButtonFormField<TipoReunion>(
                    initialValue: _tipoReunion,
                    decoration: const InputDecoration(
                      labelText: "Tipo de reunión",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TipoReunion.soloMiembros,
                        child: Text("Solo miembros"),
                      ),
                      DropdownMenuItem(
                        value: TipoReunion.abierta,
                        child: Text("Abierta"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _tipoReunion = value);
                      }
                    },
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.body.copyWith(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 140,
                        child: AppButton(
                          text: "Cancelar",
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(
                        width: 170,
                        child: AppButton(
                          text: _isSaving ? "Guardando..." : "Crear reunión",
                          onPressed: _isSaving ? null : _crearReunion,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo simple tipo "input" que abre un selector (fecha u hora)
/// al tocarlo, reutilizando el estilo de AppTextField mediante InkWell.
class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, size: 18),
          border: const OutlineInputBorder(),
        ),
        child: Text(value, style: AppTextStyles.body),
      ),
    );
  }
}