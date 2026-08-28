import 'package:flutter/material.dart';

import '../../core/storage/session_manager.dart';
import '../../core/routes/app_routes.dart';

class MainLayout extends StatefulWidget {
  final String title;
  final Widget sidebar;
  final Widget child;

  const MainLayout({
    super.key,
    required this.title,
    required this.sidebar,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String? _nombre;
  String? _rol;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await SessionManager.getUsuario();
    if (!mounted) return;
    setState(() {
      _nombre = usuario?['nombre']?.toString();
      _rol = usuario?['rol']?.toString();
    });
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Seguro que querés salir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await SessionManager.clearSession();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  String _iniciales(String? nombre) {
    if (nombre == null || nombre.trim().isEmpty) return "?";
    final partes = nombre.trim().split(RegExp(r'\s+'));
    final primera = partes.first.isNotEmpty ? partes.first[0] : '';
    final segunda =
        partes.length > 1 && partes.last.isNotEmpty ? partes.last[0] : '';
    return (primera + segunda).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          CircleAvatar(
            radius: 16,
            child: Text(
              _iniciales(_nombre),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nombre ?? "Cargando...",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (_rol != null)
                  Text(
                    _rol!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: _cerrarSesion,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          widget.sidebar,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}