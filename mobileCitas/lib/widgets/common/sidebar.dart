import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/storage/session_manager.dart';
import '../../core/routes/app_routes.dart';
import '../../main.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  /// Si se pasa, solo se muestran los ítems cuyo índice esté en el set
  /// (el índice real que usa HomeScreen para el switch, no la posición
  /// visual). null = mostrar todos.
  final Set<int>? visibleIndices;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.visibleIndices,
  });

  bool _visible(int index) =>
      visibleIndices == null || visibleIndices!.contains(index);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            "Sistema",
            style: AppTextStyles.sidebar,
          ),
          const SizedBox(height: 30),
          if (_visible(0))
            _buildItem(context: context, index: 0, icon: Icons.home_outlined, title: "Inicio"),
          if (_visible(1))
            _buildItem(
              context: context,
              index: 1,
              icon: Icons.calendar_month_outlined,
              title: "Reuniones",
            ),
          if (_visible(2))
            _buildItem(context: context, index: 2, icon: Icons.people_outline, title: "Usuarios"),
          if (_visible(3))
            _buildItem(
              context: context,
              index: 3,
              icon: Icons.fact_check_outlined,
              title: "Asistencia",
            ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.white24, height: 1),
          ),
          const SizedBox(height: 8),
          _SidebarItem(
            icon: Icons.qr_code_scanner,
            title: "Escanear QR",
            selected: false,
            onTap: () {
              if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                Scaffold.of(context).closeDrawer();
              }
              Navigator.pushNamed(context, AppRoutes.attendanceScanner);
            },
          ),
          const Spacer(),
          const Divider(color: Colors.white24, height: 1),
          _SidebarItem(
            icon: Icons.logout,
            title: "Cerrar sesión",
            selected: false,
            onTap: () => _confirmarCierreSesion(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _confirmarCierreSesion(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro que deseas cerrar tu sesión actual?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SessionManager.clearSession();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  Widget _buildItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool selected = selectedIndex == index;
    return _SidebarItem(
      icon: icon,
      title: title,
      selected: selected,
      onTap: () {
        onItemSelected(index);
        if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
          Scaffold.of(context).closeDrawer();
        }
      },
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.selected
        ? AppColors.sidebarSelected
        : _isHovered
            ? AppColors.sidebarSelected.withOpacity(0.15)
            : Colors.transparent;

return MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: Material(
    color: Colors.transparent,
    child: Ink(
      color: backgroundColor,
      child: ListTile(
        selected: widget.selected,
        leading: Icon(widget.icon, color: Colors.white),
        title: Text(widget.title, style: AppTextStyles.sidebar),
        onTap: widget.onTap,
      ),
    ),
  ),
);
  }
}