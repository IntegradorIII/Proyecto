import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../models/user.dart';
import '../../models/participant.dart';
import '/core/services/meeting_service.dart';
import '/core/services/user_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class MeetingParticipantsScreen extends StatefulWidget {
  final int meetingId;
  final String meetingTitle;

  const MeetingParticipantsScreen({
    super.key,
    required this.meetingId,
    required this.meetingTitle,
  });

  @override
  State<MeetingParticipantsScreen> createState() =>
      _MeetingParticipantsScreenState();
}

class _MeetingParticipantsScreenState
    extends State<MeetingParticipantsScreen> {
  final MeetingService _meetingService = MeetingService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _usuarios = [];
  List<Participant> _yaAsociados = [];
  Set<int> _asociadosIds = {};
  final Set<int> _seleccionados = {};

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool _sinPermiso = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sinPermiso = false;
    });

    try {
      final asociados =
          await _meetingService.listarParticipantes(widget.meetingId);

      setState(() {
        _yaAsociados = asociados;
        _asociadosIds = asociados.map((p) => p.userId).toSet();
      });

      try {
        final usuarios = await _userService.listarUsuarios();
        if (!mounted) return;
        setState(() => _usuarios = usuarios);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _sinPermiso = true;
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  List<User> get _usuariosFiltrados {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _usuarios;

    return _usuarios.where((u) {
      return u.name.toLowerCase().contains(query) ||
          u.iden.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _asociarSeleccionados() async {
    if (_seleccionados.isEmpty) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final errores = <String>[];

    for (final usuarioId in _seleccionados) {
      try {
        await _meetingService.asociarParticipante(
          eventoId: widget.meetingId,
          usuarioId: usuarioId,
        );
      } catch (e) {
        final usuario = _usuarios.firstWhere(
          (u) => u.id == usuarioId,
          orElse: () => User(
            id: usuarioId,
            name: "ID $usuarioId",
            iden: '',
            email: '',
            role: '',
          ),
        );
        errores.add(
          "${usuario.name}: ${e.toString().replaceFirst("Exception: ", "")}",
        );
      }
    }

    _seleccionados.clear();
    await _cargarDatos();

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (errores.isNotEmpty) _errorMessage = errores.join("\n");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Participantes · ${widget.meetingTitle}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ya asociados (${_yaAsociados.length})",
                    style: AppTextStyles.heading,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  if (_yaAsociados.isEmpty)
                    Text(
                      "Todavía no hay participantes en esta reunión.",
                      style: AppTextStyles.body,
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _yaAsociados.map((p) {
                        return Chip(
                          label: Text(p.user?.name ?? "Usuario"),
                          avatar: const Icon(Icons.check, size: 16),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    "Agregar participantes",
                    style: AppTextStyles.heading,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Expanded(child: _buildSelector()),
                ],
              ),
            ),
    );
  }

  Widget _buildSelector() {
    if (_sinPermiso) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text(
            "No tenés permisos para ver la lista de usuarios "
            "(se requiere rol Administrador).\n${_errorMessage ?? ''}",
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _searchController,
          label: "Buscar por nombre, cédula o correo",
          prefixIcon: Icons.search,
        ),

        const SizedBox(height: AppSpacing.md),

        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: AppTextStyles.body.copyWith(color: Colors.red),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        Expanded(
          child: _usuariosFiltrados.isEmpty
              ? Center(
                  child: Text(
                    "No hay usuarios que coincidan",
                    style: AppTextStyles.body,
                  ),
                )
              : ListView.builder(
                  itemCount: _usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final usuario = _usuariosFiltrados[index];
                    final yaAsociado = _asociadosIds.contains(usuario.id);

                    return CheckboxListTile(
                      value:
                          yaAsociado || _seleccionados.contains(usuario.id),
                      onChanged: yaAsociado
                          ? null
                          : (checked) {
                              setState(() {
                                if (checked == true) {
                                  _seleccionados.add(usuario.id);
                                } else {
                                  _seleccionados.remove(usuario.id);
                                }
                              });
                            },
                      title: Text(usuario.name),
                      subtitle: Text("${usuario.iden} · ${usuario.role}"),
                      secondary: yaAsociado
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    );
                  },
                ),
        ),

        const SizedBox(height: AppSpacing.lg),

        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: _isSaving
                ? "Asociando..."
                : "Asociar seleccionados (${_seleccionados.length})",
            onPressed: (_isSaving || _seleccionados.isEmpty)
                ? null
                : _asociarSeleccionados,
          ),
        ),
      ],
    );
  }
}