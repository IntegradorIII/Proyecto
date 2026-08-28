import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../../core/storage/session_manager.dart';
import '../../models/meeting.dart';
import '/core/services/meeting_service.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_textfield.dart';
import '../../widgets/meeting/meeting_card.dart';
import 'create_meeting_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final MeetingService _meetingService = MeetingService();
  final TextEditingController _searchController = TextEditingController();

  List<Meeting> _meetings = [];
  List<Meeting> _filteredMeetings = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _puedeCrear = false;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
    _cargarPermiso();
    _searchController.addListener(_applyFilter);
  }

  Future<void> _cargarPermiso() async {
    final puede = await SessionManager.puedeGestionarEventos();
    if (mounted) setState(() => _puedeCrear = puede);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeetings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meetings = await _meetingService.getMeetings();
      setState(() {
        _meetings = meetings;
        _filteredMeetings = meetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredMeetings = query.isEmpty
          ? _meetings
          : _meetings.where((m) {
              return m.title.toLowerCase().contains(query) ||
                  m.location.toLowerCase().contains(query);
            }).toList();
    });
  }

  Future<void> _goToCreateMeeting() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateMeetingScreen(),
      ),
    );

    if (created == true) {
      _loadMeetings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Reuniones",
              style: AppTextStyles.pageTitle,
            ),
            if (_puedeCrear)
              SizedBox(
                width: 180,
                child: AppButton(
                  text: "Crear reunión",
                  onPressed: _goToCreateMeeting,
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          controller: _searchController,
          label: "Buscar reunión",
          prefixIcon: Icons.search,
        ),

        const SizedBox(height: AppSpacing.lg),

        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: "Reintentar",
              onPressed: _loadMeetings,
            ),
          ],
        ),
      );
    }

    if (_filteredMeetings.isEmpty) {
      return Center(
        child: Text(
          "No hay reuniones para mostrar",
          style: AppTextStyles.body,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMeetings,
      child: ListView.builder(
        itemCount: _filteredMeetings.length,
        itemBuilder: (context, index) {
          final meeting = _filteredMeetings[index];

          return MeetingCard(meeting: meeting);
        },
      ),
    );
  }
}