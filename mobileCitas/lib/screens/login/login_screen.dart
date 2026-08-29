import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/attendance_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';

class LoginScreen extends StatefulWidget {
  final int? meetingId;

  const LoginScreen({super.key, this.meetingId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _attendanceService = AttendanceService();

  bool _isLoading = false;

  int? get _resolvedMeetingId {
    if (widget.meetingId != null) return widget.meetingId;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) return args;
    if (args is String) return int.tryParse(args);
    return null;
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text;

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete correo y contraseña")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = AuthService();

    try {
      final login = await auth.login(
        correo: correo,
        password: password,
      );

      await SessionManager.saveSession(
        token: login.token,
        usuario: {
          "id": login.usuario.id,
          "nombre": login.usuario.name,
          "correo": login.usuario.email,
          "rol": login.usuario.role,
        },
      );

      final meetingId = _resolvedMeetingId;
      if (meetingId != null && meetingId > 0) {
        try {
          final asistencia = await _attendanceService.checkInQR(
            userId: login.usuario.id,
            eventId: meetingId,
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "¡Bienvenido! Asistencia registrada como ${asistencia.estado}.",
              ),
              backgroundColor: Colors.green,
            ),
          );
        } catch (asistenciaError) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Inicio de sesión exitoso. ${asistenciaError.toString().replaceFirst('Exception: ', '')}",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingId = _resolvedMeetingId;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            width: 400,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (meetingId != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.indigo.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.meeting_room, color: Colors.indigo, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Convocado a Reunión #$meetingId. Inicia sesión para confirmar tu asistencia.",
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.indigo.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    Text(
                      "Sistema de Asistencia",
                      style: AppTextStyles.pageTitle,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "Inicio de Sesión para Miembros",
                      style: AppTextStyles.body.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    AppTextField(
                      label: "Correo Electrónico",
                      controller: _correoController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: "Contraseña",
                      obscureText: true,
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    AppButton(
                      text: meetingId != null
                          ? "Iniciar sesión e Ingresar"
                          : "Iniciar sesión",
                      isLoading: _isLoading,
                      onPressed: _login,
                      icon: Icons.login,
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