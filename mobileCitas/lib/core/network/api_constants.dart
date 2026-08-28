import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  // Puerto de tu backend local (ajustar según el backend, ej. 3000, 8000, 8080)
  static const String _localPort = '8080';
  // IP de tu máquina en la red local (para dispositivos físicos)
  static const String _localIp = '192.168.1.100'; 

  static String get baseUrl {
    // Apuntar a la URL pública de producción en Render
    return 'https://backend-citas-8z3g.onrender.com';
  }

  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}