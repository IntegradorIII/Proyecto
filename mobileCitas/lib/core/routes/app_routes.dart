import 'package:flutter/material.dart';

import '../../screens/login/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/attendance/attendance_scanner_screen.dart';
import '../storage/session_manager.dart';

class AppRoutes {
  static const login = "/";
  static const home = "/home";
  static const meetings = "/meetings";
  static const attendance = "/attendance";
  static const attendanceScanner = "/attendance/scanner";
  static const users = "/users";

  /// Generador de rutas que actúa como Route Guard / Middleware
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final bool isAuthenticated = SessionManager.isAuthenticated;

    // Si NO está autenticado y trata de ir a cualquier ruta protegida (distinta de login),
    // lo redirigimos forzosamente al login.
    if (!isAuthenticated && settings.name != login) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }

    // Si SÍ está autenticado y trata de ir a la pantalla de login,
    // lo redirigimos forzosamente a la pantalla principal.
    if (isAuthenticated && settings.name == login) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    }

    // Mapeo de rutas estándar
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case attendanceScanner:
        return MaterialPageRoute(builder: (_) => const AttendanceScannerScreen());
      default:
        // Ruta por defecto o error (fallback)
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("Ruta no encontrada: ${settings.name}"),
            ),
          ),
        );
    }
  }
}