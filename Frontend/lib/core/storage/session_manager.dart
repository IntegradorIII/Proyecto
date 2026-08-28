import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static const String _tokenKey = "jwt_token";
  static const String _usuarioKey = "usuario_actual";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUsuario(Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usuarioKey, jsonEncode(usuario));
  }

  static Future<Map<String, dynamic>?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usuarioKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<String?> getRol() async {
    final usuario = await getUsuario();
    return usuario?['rol']?.toString();
  }

  static Future<bool> isAdmin() async {
    final rol = await getRol();
    return rol == 'Administrador';
  }

  static Future<bool> puedeGestionarEventos() async {
    final rol = await getRol();
    return rol == 'Administrador' || rol == 'Operador';
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usuarioKey);
  }

  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }
}