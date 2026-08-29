import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user.dart';
import '/core/services/user_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _cedulaController;
  late TextEditingController _correoController;
  late TextEditingController _passwordController;
  late String _rolSeleccionado;

  bool _obscurePassword = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.name);
    _cedulaController = TextEditingController(text: widget.user.iden);
    _correoController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();

    if (kRolesUsuario.contains(widget.user.role)) {
      _rolSeleccionado = widget.user.role;
    } else {
      _rolSeleccionado = kRolesUsuario.first;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _editar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombre = _nombreController.text.trim();
    final cedula = _cedulaController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _userService.editarUsuario(
        id: widget.user.id,
        nombre: nombre,
        cedula: cedula,
        correo: correo,
        rol: _rolSeleccionado,
        password: password.isNotEmpty ? password : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario actualizado exitosamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Editar usuario",
                  style: AppTextStyles.pageTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Modifica los datos del usuario o cambia su contraseña.",
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _nombreController,
                  label: "Nombre completo",
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Obligatorio" : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _cedulaController,
                  label: "Cédula",
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Obligatorio" : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _correoController,
                  label: "Correo",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Obligatorio";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return "Correo inválido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _passwordController,
                  label: "Nueva contraseña (opcional)",
                  obscureText: _obscurePassword,
                  helperText: "Dejar en blanco para conservar la contraseña actual",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty && v.trim().length < 5) {
                      return "La contraseña debe tener al menos 5 caracteres";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: _rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Rol",
                    border: OutlineInputBorder(),
                  ),
                  items: kRolesUsuario
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _rolSeleccionado = value);
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
                    Flexible(
                      child: TextButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: AppButton(
                        text: "Guardar",
                        isLoading: _isSaving,
                        onPressed: _editar,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
