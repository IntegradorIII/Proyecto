import 'package:flutter/material.dart';
import '../../core/storage/session_manager.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget sidebar;
  final Widget child;

  const MainLayout({
    super.key,
    required this.title,
    required this.sidebar,
    required this.child,
  });

  String _iniciales(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    final partes = name.trim().split(RegExp(r'\s+'));
    final primera = partes.first.isNotEmpty ? partes.first[0] : '';
    final segunda =
        partes.length > 1 && partes.last.isNotEmpty ? partes.last[0] : '';
    return (primera + segunda).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessionManager.currentUser;
    final String nombre = usuario?['nombre']?.toString() ?? 'Invitado';
    final String rol = usuario?['rol']?.toString() ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Escanear QR',
                onPressed: () {
                  Navigator.pushNamed(context, '/attendance/scanner');
                },
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                child: Text(
                  _iniciales(nombre),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    if (rol.isNotEmpty)
                      Text(
                        rol,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
          drawer: isMobile ? Drawer(child: sidebar) : null,
          body: isMobile
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                )
              : Row(
                  children: [
                    sidebar,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: child,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}