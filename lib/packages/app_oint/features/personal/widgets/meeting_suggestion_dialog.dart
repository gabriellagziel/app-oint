import 'package:flutter/material.dart';
import '../services/meeting_suggestion_service.dart';

class MeetingSuggestionDialog extends StatelessWidget {
  final String meetingId;
  final MeetingSuggestionService _service = MeetingSuggestionService();

  MeetingSuggestionDialog({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Meeting Ended'),
      content: const Text(
        'Would you like to reschedule or duplicate this meeting?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            _service.markSuggestionShown(meetingId);
            Navigator.pop(context);
          },
          child: const Text('No, thanks'),
        ),
        FilledButton(
          onPressed: () async {
            await _showRescheduleDialog(context);
          },
          child: const Text('Reschedule'),
        ),
        FilledButton(
          onPressed: () async {
            await _service.duplicateMeeting(meetingId);
            await _service.markSuggestionShown(meetingId);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Duplicate'),
        ),
      ],
    );
  }

  Future<void> _showRescheduleDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reschedule Meeting'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            selectedDate = date;
                          }
                        },
                        child: Text(_formatDate(selectedDate)),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            selectedTime = time;
                          }
                        },
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final newTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  await _service.rescheduleMeeting(meetingId, newTime);
                  await _service.markSuggestionShown(meetingId);
                  if (context.mounted) {
                    Navigator.pop(context); // Close reschedule dialog
                    Navigator.pop(context); // Close suggestion dialog
                  }
                },
                child: const Text('Reschedule'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
