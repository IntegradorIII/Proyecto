import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/meeting.dart';
import 'meeting_details_dialog.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingCard({
    super.key,
    required this.meeting,
  });

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
                meeting: meeting,
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
              Text(
                meeting.title,
                style: AppTextStyles.heading,
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
                    _formatDate(meeting.dateTime),
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
                      meeting.location,
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
                    "Tolerancia: ${meeting.toleranceMinutes} min",
                    style: AppTextStyles.body,
                  ),
                ],
              ),

              if (meeting.participants > 0) ...[
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
                      "${meeting.participants} participantes",
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
}