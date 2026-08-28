import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/session_manager.dart';

// Clave global de navegación para redirecciones desde fuera de widgets (ej. interceptores Dio)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Asegurar que los bindings de Flutter estén inicializados antes de correr código asíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar SessionManager síncronamente al arrancar la app
  await SessionManager.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Asistencia',
      theme: AppTheme.lightTheme,
      
      // Asignamos la clave global de navegación
      navigatorKey: navigatorKey,
      
      // Decidimos la ruta inicial basándonos en si hay sesión de forma síncrona,
      // evitando la necesidad de un SplashScreen parpadeante.
      initialRoute: SessionManager.isAuthenticated ? AppRoutes.home : AppRoutes.login,
      
      // Usamos onGenerateRoute como Route Guard en lugar de routes estáticas
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}