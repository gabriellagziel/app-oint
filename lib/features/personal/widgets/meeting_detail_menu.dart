import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meeting_action_providers.dart';

class MeetingDetailMenu extends ConsumerWidget {
  final String meetingId;

  const MeetingDetailMenu({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCreator = ref.watch(isMeetingCreatorProvider(meetingId));

    return isCreator.when(
      data: (isCreator) {
        if (!isCreator) return const SizedBox.shrink();

        return PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reschedule',
                  child: Row(
                    children: [
                      Icon(Icons.schedule),
                      SizedBox(width: 8),
                      Text('Reschedule'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel),
                      SizedBox(width: 8),
                      Text('Cancel'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reminder',
                  child: Row(
                    children: [
                      Icon(Icons.notifications),
                      SizedBox(width: 8),
                      Text('Send Reminder'),
                    ],
                  ),
                ),
              ],
          onSelected: (value) => _handleAction(context, ref, value),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final service = ref.read(meetingActionServiceProvider);

    try {
      switch (action) {
        case 'duplicate':
          await service.duplicateMeeting(meetingId);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Meeting duplicated')));
          }
          break;

        case 'reschedule':
          if (context.mounted) {
            await _showRescheduleDialog(context, ref);
          }
          break;

        case 'cancel':
          if (context.mounted) {
            final confirmed = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Cancel Meeting'),
                    content: const Text(
                      'Are you sure you want to cancel this meeting?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
            );

            if (confirmed == true) {
              await service.cancelMeeting(meetingId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meeting cancelled')),
                );
              }
            }
          }
          break;

        case 'reminder':
          await service.sendReminder(meetingId);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Reminder sent')));
          }
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showRescheduleDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
                  await ref
                      .read(meetingActionServiceProvider)
                      .rescheduleMeeting(meetingId, newTime);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meeting rescheduled')),
                    );
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
