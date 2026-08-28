import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../models/user.dart';
import '/core/services/user_service.dart';

import '../../widgets/common/app_button.dart';

import 'create_user_screen.dart' as create;
import 'edit_user_dialog.dart' as edit;

/// Pantalla de administración de usuarios. Solo funciona para una sesión
/// con rol 'Administrador' (el backend responde 403 si no lo es).
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService _userService = UserService();

  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _userService.listarUsuarios();
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _goToCreateUser() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const create.CreateUserScreen(),
      ),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _editUser(User user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => edit.EditUserDialog(user: user),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _confirmDelete(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        title: const Text("Eliminar usuario"),
        content: Text("¿Estás seguro de eliminar a ${user.name}? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _userService.eliminarUsuario(user.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado exitosamente")),
        );
        _loadUsers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Administrador':
        return Colors.red.shade100;
      case 'Operador':
        return Colors.blue.shade100;
      case 'Miembro':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getRoleTextColor(String role) {
    switch (role) {
      case 'Administrador':
        return Colors.red.shade900;
      case 'Operador':
        return Colors.blue.shade900;
      case 'Miembro':
        return Colors.green.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateUser,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: AppSpacing.md),
            Text(_errorMessage!, style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: "Reintentar",
              onPressed: _loadUsers,
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text("No hay usuarios registrados.", style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: AppTextStyles.heading,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Chip(
                    label: Text(
                      user.role,
                      style: TextStyle(
                        color: _getRoleTextColor(user.role),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: _getRoleColor(user.role),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(user.iden.isNotEmpty ? user.iden : "Sin cédula", style: AppTextStyles.body),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.email,
                            style: AppTextStyles.body,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _editUser(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}