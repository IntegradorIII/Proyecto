import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
              const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.only(right: 24),
                child: Center(
                  child: Text("Invitado"),
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