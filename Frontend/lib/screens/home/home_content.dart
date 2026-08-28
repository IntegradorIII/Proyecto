import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/meeting.dart';
import '/core/services/meeting_service.dart';
import '../../widgets/meeting/meeting_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final MeetingService _meetingService = MeetingService();

  List<Meeting> _meetings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meetings = await _meetingService.getMeetings();
      setState(() {
        // El backend ya ordena por fecha ASC; mostramos las próximas 2.
        _meetings = meetings.take(2).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMeetings,
      child: ListView(
        children: [
          Text(
            "Bienvenido",
            style: AppTextStyles.pageTitle,
          ),

          const SizedBox(height: AppSpacing.sm),

          const Text(
            "Administre reuniones y registre la asistencia de los participantes.",
            style: AppTextStyles.body,
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            "Próximas reuniones",
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: AppSpacing.md),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(_errorMessage!, style: AppTextStyles.body),
            )
          else if (_meetings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                "No hay reuniones próximas",
                style: AppTextStyles.body,
              ),
            )
          else
            ..._meetings.map(
              (meeting) => MeetingCard(
                meeting: meeting,
              ),
            ),
        ],
      ),
    );
  }
}