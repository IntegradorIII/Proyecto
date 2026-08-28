import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../core/services/auth_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = AuthService();

    try {
      final login = await auth.login(
        correo: _correoController.text,
        password: _passwordController.text,
      );

      // Guardamos token y usuario usando el nuevo método unificado
      await SessionManager.saveSession(
        token: login.token,
        usuario: {
          "id": login.usuario.id,
          "nombre": login.usuario.name,
          "correo": login.usuario.email,
          "rol": login.usuario.role,
        },
      );

      if (!mounted) return;

      // Navegación segura
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Sistema de Asistencia",
                  style: AppTextStyles.pageTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  label: "Correo",
                  controller: _correoController,
                ),

                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: "Contraseña",
                  obscureText: true,
                  controller: _passwordController,
                ),

                const SizedBox(height: AppSpacing.lg),

                AppButton(
                  text: "Iniciar sesión",
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}