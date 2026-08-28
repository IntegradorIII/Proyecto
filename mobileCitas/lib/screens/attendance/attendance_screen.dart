import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/storage/session_manager.dart';
import '../../models/meeting.dart';
import '/core/services/meeting_service.dart';

import 'attendance_checkin_screen.dart';
import 'attendance_report_screen.dart';


class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final MeetingService _meetingService = MeetingService();

  List<Meeting> _meetings = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meetings = await _meetingService.getMeetings();
      final adminStatus = SessionManager.isAdmin;

      final now = DateTime.now();

      final futuras = meetings.where((m) => !m.dateTime.isBefore(now)).toList();
      final pasadas = meetings.where((m) => m.dateTime.isBefore(now)).toList();

      futuras.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      pasadas.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      final sortedMeetings = [...futuras, ...pasadas];

      if (!mounted) return;
      setState(() {
        _meetings = sortedMeetings;
        _isAdmin = adminStatus;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Asistencia", style: AppTextStyles.pageTitle),

        const SizedBox(height: AppSpacing.sm),

        Text(
          _isAdmin
              ? "Elegí una reunión para marcar asistencia o ver su reporte."
              : "Elegí una reunión para marcar asistencia.",
          style: AppTextStyles.body,
        ),

        const SizedBox(height: AppSpacing.lg),

        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: AppTextStyles.body));
    }

    if (_meetings.isEmpty) {
      return Center(
        child: Text("No hay reuniones todavía", style: AppTextStyles.body),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];

          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              title: Text(meeting.title),
              subtitle: Text(meeting.location),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.how_to_reg_outlined),
                    tooltip: "Marcar asistencia",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AttendanceCheckinScreen(meeting: meeting),
                        ),
                      );
                    },
                  ),
                  if (_isAdmin)
                    IconButton(
                      icon: const Icon(Icons.bar_chart_outlined),
                      tooltip: "Ver reporte",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttendanceReportScreen(
                              meetingId: meeting.id,
                              meetingTitle: meeting.title,
                            ),
                          ),
                        );
                      },
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