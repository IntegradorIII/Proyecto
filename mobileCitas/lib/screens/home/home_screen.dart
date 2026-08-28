import 'package:flutter/material.dart';

import '../../core/storage/session_manager.dart';

import '../attendance/attendance_screen.dart';
import '../meetings/meetings_screen.dart';
import '../users/users_screen.dart';
import 'home_content.dart';
import '../../widgets/common/main_layout.dart';
import '../../widgets/common/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Set<int> _visibleIndices = {0, 1};

  @override
  void initState() {
    super.initState();
    _cargarPermisos();
  }

  void _cargarPermisos() {
    // Lectura síncrona directamente desde el caché en memoria
    final isAdmin = SessionManager.isAdmin;
    final puedeGestionar = SessionManager.puedeGestionarEventos;

    setState(() {
      _visibleIndices = {
        0,
        1,
        if (isAdmin) 2,
        if (puedeGestionar) 3,
      };

      if (!_visibleIndices.contains(_selectedIndex)) {
        _selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Sistema de Asistencia",
      sidebar: Sidebar(
        selectedIndex: _selectedIndex,
        visibleIndices: _visibleIndices,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const HomeContent();
      case 1:
        return const MeetingsScreen();
      case 2:
        return const UserScreen();
      case 3:
        return const AttendanceScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}