import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meeting_creation_provider.dart';
import '../utils/localizations_helper.dart';

/// Widget for displaying meeting summary before confirmation
class MeetingStepSummary extends ConsumerWidget {
  const MeetingStepSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meetingCreationProvider);

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
            const SizedBox(height: 24),
            _buildInfoRow(
              context,
              LocalizationsHelper.getString(context, 'meeting_type'),
              state.type?.name ??
                  LocalizationsHelper.getString(context, 'none'),
            ),
            _buildInfoRow(
              context,
              LocalizationsHelper.getString(context, 'meeting_date'),
              state.dateTime != null
                  ? MaterialLocalizations.of(context)
                      .formatFullDate(state.dateTime!)
                  : LocalizationsHelper.getString(context, 'none'),
            ),
            _buildInfoRow(
              context,
              LocalizationsHelper.getString(context, 'meeting_time'),
              state.dateTime != null
                  ? MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay.fromDateTime(state.dateTime!),
                    )
                  : LocalizationsHelper.getString(context, 'none'),
            ),
            _buildInfoRow(
              context,
              LocalizationsHelper.getString(context, 'meeting_participants'),
              state.participants.isEmpty
                  ? LocalizationsHelper.getString(context, 'none')
                  : state.participants.join(', '),
            ),
            if (state.location != null)
              _buildInfoRow(
                context,
                LocalizationsHelper.getString(context, 'meeting_location'),
                state.location!.name,
              ),
            if (state.notes.isNotEmpty)
              _buildInfoRow(
                context,
                LocalizationsHelper.getString(context, 'meeting_notes'),
                state.notes,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.type != null &&
                        state.dateTime != null &&
                        state.participants.isNotEmpty
                    ? () {
                        ref.read(meetingCreationProvider.notifier).submit();
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Text(LocalizationsHelper.getString(
                    context, 'meeting_creation_confirm')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
