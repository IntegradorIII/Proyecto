import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/storage/session_manager.dart';

import '../../models/attendance.dart';
import '/core/services/attendance_service.dart';

/// GET /eventos/:id/reporte -> requiere rol Administrador.
class AttendanceReportScreen extends StatefulWidget {
  final int meetingId;
  final String meetingTitle;

  const AttendanceReportScreen({
    super.key,
    required this.meetingId,
    required this.meetingTitle,
  });

  @override
  State<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final AttendanceService _attendanceService = AttendanceService();

  AttendanceReport? _report;
  bool _isLoading = true;
  bool _sinPermiso = false;
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
      _sinPermiso = false;
    });

    final esAdmin = await SessionManager.isAdmin();
    if (!esAdmin) {
      setState(() {
        _sinPermiso = true;
        _isLoading = false;
      });
      return;
    }

    try {
      final report = await _attendanceService.report(widget.meetingId);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  String _statusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return "Presente";
      case AttendanceStatus.late:
        return "Tardío";
      case AttendanceStatus.absent:
        return "Ausente";
    }
  }

  Color _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reporte · ${widget.meetingTitle}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sinPermiso
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      "Este reporte requiere rol Administrador.",
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Text(_errorMessage!, style: AppTextStyles.body),
                    )
                  : _buildReport(),
    );
  }

  Widget _buildReport() {
    final report = _report!;

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryCard("Total", report.total, Colors.blueGrey),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _summaryCard(
                  "Presentes",
                  report.present,
                  Colors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _summaryCard("Tardíos", report.late, Colors.orange),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _summaryCard("Ausentes", report.absent, Colors.red),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          Text("Detalle", style: AppTextStyles.heading),

          const SizedBox(height: AppSpacing.sm),

          ...report.detail.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text("${item.identification} · ${item.email}"),
                trailing: Text(
                  _statusLabel(item.status),
                  style: AppTextStyles.body.copyWith(
                    color: _statusColor(item.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int value, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Text(
              "$value",
              style: AppTextStyles.pageTitle.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
