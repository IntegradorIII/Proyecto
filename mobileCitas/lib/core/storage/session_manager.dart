import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static const String _tokenKey = "jwt_token";
  static const String _usuarioKey = "usuario_actual";

  static late SharedPreferences _prefs;
  
  // Caché en memoria para acceso síncrono
  static String? _token;
  static Map<String, dynamic>? _usuario;

  /// Inicializa las preferencias y carga la sesión en memoria.
  /// Debe llamarse una sola vez en main.dart antes de runApp.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs.getString(_tokenKey);
    final raw = _prefs.getString(_usuarioKey);
    if (raw != null) {
      _usuario = jsonDecode(raw) as Map<String, dynamic>;
    }
  }

  /// Guarda la sesión tanto en SharedPreferences como en la caché en memoria.
  static Future<void> saveSession({
    required String token, 
    required Map<String, dynamic> usuario
  }) async {
    _token = token;
    _usuario = usuario;
    
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_usuarioKey, jsonEncode(usuario));
  }

  /// Limpia la sesión actual de SharedPreferences y de la memoria.
  static Future<void> clearSession() async {
    _token = null;
    _usuario = null;
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_usuarioKey);
  }

  // ==========================================
  // GETTERS SÍNCRONOS
  // ==========================================

  /// Verifica si existe un token en memoria.
  static bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Retorna el token JWT actual.
  static String? get token => _token;

  /// Retorna los datos del usuario actual.
  static Map<String, dynamic>? get currentUser => _usuario;

  /// Retorna el rol del usuario actual.
  static String? get userRole => _usuario?['rol']?.toString();

  /// Retorna true si el usuario actual es Administrador.
  static bool get isAdmin => userRole == 'Administrador';

  /// Retorna true si el usuario actual tiene permisos para gestionar eventos (Admin u Operador).
  static bool get puedeGestionarEventos {
    return userRole == 'Administrador' || userRole == 'Operador';
  }
}