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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final bool isAuthenticated = SessionManager.isAuthenticated;

    final bool isPublicRoute = settings.name == login;

    if (!isAuthenticated && !isPublicRoute) {
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
        settings: settings,
      );
    }

    if (isAuthenticated && settings.name == login && settings.arguments == null) {
      return MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: settings,
      );
    }

   
    switch (settings.name) {
      case login:
        final meetingId = settings.arguments is int
            ? settings.arguments as int
            : (settings.arguments is String ? int.tryParse(settings.arguments as String) : null);
        return MaterialPageRoute(
          builder: (_) => LoginScreen(meetingId: meetingId),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case attendanceScanner:
        return MaterialPageRoute(
          builder: (_) => const AttendanceScannerScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("Ruta no encontrada: ${settings.name}"),
            ),
          ),
          settings: settings,
        );
    }
  }
}