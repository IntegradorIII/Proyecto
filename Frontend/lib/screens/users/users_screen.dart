import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../models/user.dart';
import '/core/services/user_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

/// Pantalla de administración de usuarios. Solo funciona para una sesión
/// con rol 'Administrador' (el backend responde 403 si no lo es).
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService _userService = UserService();

  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = kRolesUsuario.first;

  bool _isSaving = false;
  String? _errorMessage;
  User? _ultimoRegistrado;

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final cedula = _cedulaController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text;

    if (nombre.isEmpty ||
        cedula.isEmpty ||
        correo.isEmpty ||
        password.isEmpty) {
      setState(() => _errorMessage = "Complete todos los campos");
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final usuario = await _userService.registrarUsuario(
        nombre: nombre,
        cedula: cedula,
        correo: correo,
        password: password,
        rol: _rolSeleccionado,
      );

      _nombreController.clear();
      _cedulaController.clear();
      _correoController.clear();
      _passwordController.clear();

      setState(() {
        _ultimoRegistrado = usuario;
        _isSaving = false;
      });
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
        title: const Text("Registrar usuario"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
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
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _cedulaController,
                    label: "Cédula",
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _correoController,
                    label: "Correo",
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    obscureText: true,
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

                  if (_ultimoRegistrado != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      "Registrado: ${_ultimoRegistrado!.name} "
                      "(id ${_ultimoRegistrado!.id})",
                      style: AppTextStyles.body.copyWith(color: Colors.green),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: _isSaving ? "Guardando..." : "Registrar",
                      onPressed: _isSaving ? null : _registrar,
                    ),
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