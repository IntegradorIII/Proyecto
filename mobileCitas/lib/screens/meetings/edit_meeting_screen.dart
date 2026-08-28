import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../models/meeting.dart';
import '/core/services/meeting_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class EditMeetingScreen extends StatefulWidget {
  final Meeting meeting;

  const EditMeetingScreen({super.key, required this.meeting});

  @override
  State<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends State<EditMeetingScreen> {
  final MeetingService _meetingService = MeetingService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _lugarController;
  late TextEditingController _toleranciaController;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  late TipoReunion _tipoReunion;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.meeting.title);
    _lugarController = TextEditingController(text: widget.meeting.location);
    _toleranciaController = TextEditingController(text: widget.meeting.toleranceMinutes.toString());
    
    _fechaSeleccionada = widget.meeting.dateTime;
    _horaSeleccionada = TimeOfDay.fromDateTime(widget.meeting.dateTime);
    _tipoReunion = widget.meeting.tipoReunion;
  }

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
      firstDate: now.subtract(const Duration(days: 365)),
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

  Future<void> _editarReunion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      setState(() {
        _errorMessage = "Por favor, seleccione fecha y hora";
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

      await _meetingService.updateMeeting(
        id: widget.meeting.id,
        title: nombre,
        date: _fechaSeleccionada!,
        time: horaStr,
        location: lugar,
        toleranceMinutes: tolerancia,
        tipoReunion: _tipoReunion,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reunión actualizada exitosamente")),
      );

      Navigator.pop(context, true);
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
          title: const Text("Editar reunión"),
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
                    "Editar reunión",
                    style: AppTextStyles.pageTitle,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Modifique la información de la reunión.",
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
                          text: "Guardar",
                          isLoading: _isSaving,
                          onPressed: _editarReunion,
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
