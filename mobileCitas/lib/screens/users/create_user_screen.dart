import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '/core/services/user_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = kRolesUsuario.first;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombre = _nombreController.text.trim();
    final cedula = _cedulaController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _userService.registrarUsuario(
        nombre: nombre,
        cedula: cedula,
        correo: correo,
        password: password,
        rol: _rolSeleccionado,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usuario registrado exitosamente"),
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Registrar usuario"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registrar usuario",
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Crea una cuenta nueva con acceso al sistema. "
                        "Requiere permisos de administrador.",
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        controller: _nombreController,
                        label: "Nombre completo",
                        validator: (v) => v == null || v.trim().isEmpty ? "Obligatorio" : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _cedulaController,
                        label: "Cédula",
                        validator: (v) => v == null || v.trim().isEmpty ? "Obligatorio" : null,
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
                        label: "Contraseña",
                        obscureText: true,
                        validator: (v) => v == null || v.length < 6 
                            ? "Mínimo 6 caracteres" : null,
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
                        children: [
                          Expanded(
                            child: AppButton(
                              text: "Cancelar",
                              onPressed: _isSaving ? null : () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: "Registrar",
                              isLoading: _isSaving,
                              onPressed: _registrar,
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
      ),
    );
  }
}
