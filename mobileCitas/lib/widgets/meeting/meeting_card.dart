import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/meeting.dart';
import '../../core/services/meeting_service.dart';
import '../../core/storage/session_manager.dart';
import 'meeting_details_dialog.dart';
import '../../screens/meetings/edit_meeting_screen.dart';

class MeetingCard extends StatefulWidget {
  final Meeting meeting;
  final VoidCallback? onChanged;

  const MeetingCard({
    super.key,
    required this.meeting,
    this.onChanged,
  });

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return MeetingDetailsDialog(
                meeting: widget.meeting,
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.meeting.title,
                      style: AppTextStyles.heading,
                    ),
                  ),
                  if (SessionManager.puedeGestionarEventos)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () => _editarReunion(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmarEliminacion(context),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  Text(
                    _formatDate(widget.meeting.dateTime),
                    style: AppTextStyles.body,
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  Expanded(
                    child: Text(
                      widget.meeting.location,
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.hourglass_bottom_outlined,
                    size: 18,
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  Text(
                    "Tolerancia: ${widget.meeting.toleranceMinutes} min",
                    style: AppTextStyles.body,
                  ),
                ],
              ),

              if (widget.meeting.participants > 0) ...[
                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 18,
                    ),

                    const SizedBox(
                      width: AppSpacing.sm,
                    ),

                    Text(
                      "${widget.meeting.participants} participantes",
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$day/$month/${date.year}   $hour:$minute";
  }

  Future<void> _editarReunion(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMeetingScreen(meeting: widget.meeting),
      ),
    );

    if (result == true) {
      widget.onChanged?.call();
    }
  }

  Future<void> _confirmarEliminacion(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        title: const Text("Eliminar reunión"),
        content: Text("¿Seguro que desea eliminar '${widget.meeting.title}'? Esta acción no se puede deshacer."),
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
        await MeetingService().deleteMeeting(widget.meeting.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reunión eliminada exitosamente")),
        );
        widget.onChanged?.call();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}