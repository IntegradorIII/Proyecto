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
  final _formKey = GlobalKey<FormState>();

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
      firstDate: now.subtract(const Duration(days: 1)),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      setState(() {
        _errorMessage = "Por favor, seleccione fecha y hora";
      });
      return;
    }

    // Pre-validación: La reunión debe crearse con al menos 30 minutos de anticipación.
    final meetingDateTime = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    if (meetingDateTime.difference(DateTime.now()).inMinutes < 30) {
      setState(() {
        _errorMessage = "La reunión debe crearse con al menos 30 minutos de anticipación.";
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

      final nombre = _nombreController.text.trim();
      final lugar = _lugarController.text.trim();
      final tolerancia = int.tryParse(_toleranciaController.text.trim()) ?? 20;

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
      // Pasamos result: true para que la pantalla anterior (MeetingsScreen)
      // reciba 'true' y recargue la lista de reuniones en segundo plano.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingParticipantsScreen(
            meetingId: creada.id,
            meetingTitle: creada.title,
          ),
        ),
        result: true,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Crear reunión"),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
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
                    validator: (value) => value == null || value.trim().isEmpty 
                        ? "El nombre es obligatorio" : null,
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
                      const SizedBox(width: 12),
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
                    validator: (value) => value == null || value.trim().isEmpty 
                        ? "El lugar es obligatorio" : null,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _toleranciaController,
                    label: "Tolerancia (minutos)",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Obligatorio";
                      if (int.tryParse(value) == null) return "Debe ser un número válido";
                      return null;
                    },
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
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Cancelar",
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: "Crear reunión",
                          isLoading: _isSaving,
                          onPressed: _crearReunion,
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