import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/providers/meeting_creation_provider.dart';
import 'package:app_oint9/utils/localizations_helper.dart';

/// Widget for displaying meeting summary
class MeetingStepSummary extends ConsumerWidget {
  const MeetingStepSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(meetingCreationProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocalizationsHelper.getString(context, 'meeting_summary_title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              context,
              icon: Icons.title,
              title:
                  LocalizationsHelper.getString(context, 'meeting_title_label'),
              value: draft.title,
            ),
            _buildSummaryItem(
              context,
              icon: Icons.calendar_today,
              title: LocalizationsHelper.getString(
                  context, 'meeting_datetime_label'),
              value: draft.datetime != null
                  ? '${draft.datetime!.day}/${draft.datetime!.month}/${draft.datetime!.year} '
                      '${draft.datetime!.hour.toString().padLeft(2, '0')}:${draft.datetime!.minute.toString().padLeft(2, '0')}'
                  : '',
            ),
            _buildSummaryItem(
              context,
              icon: Icons.group,
              title: LocalizationsHelper.getString(
                  context, 'meeting_participants_label'),
              value: draft.participants.join(', '),
            ),
            _buildSummaryItem(
              context,
              icon: Icons.location_on,
              title: LocalizationsHelper.getString(
                  context, 'meeting_location_label'),
              value: draft.location,
            ),
            if (draft.notes.isNotEmpty)
              _buildSummaryItem(
                context,
                icon: Icons.note,
                title: LocalizationsHelper.getString(
                    context, 'meeting_notes_label'),
                value: draft.notes,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
