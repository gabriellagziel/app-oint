import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifications/services/meeting_notification_service.dart';
import '../../notifications/providers/meeting_notification_providers.dart';

class LateNotificationButton extends ConsumerWidget {
  final String meetingId;
  final String participantId;

  const LateNotificationButton({
    super.key,
    required this.meetingId,
    required this.participantId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.watch(meetingNotificationServiceProvider);

    return TextButton.icon(
      onPressed: () async {
        try {
          await notificationService.sendLateNotification(
            meetingId: meetingId,
            participantId: participantId,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Late notification sent to participants'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send notification: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.timer_outlined),
      label: const Text('I\'m Running Late'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange,
      ),
    );
  }
}
