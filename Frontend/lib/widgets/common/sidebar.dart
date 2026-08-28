import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

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
            _buildItem(index: 0, icon: Icons.home_outlined, title: "Inicio"),
          if (_visible(1))
            _buildItem(
              index: 1,
              icon: Icons.calendar_month_outlined,
              title: "Reuniones",
            ),
          if (_visible(2))
            _buildItem(index: 2, icon: Icons.people_outline, title: "Usuarios"),
          if (_visible(3))
            _buildItem(
              index: 3,
              icon: Icons.fact_check_outlined,
              title: "Asistencia",
            ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool selected = selectedIndex == index;
    return _SidebarItem(
      icon: icon,
      title: title,
      selected: selected,
      onTap: () => onItemSelected(index),
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