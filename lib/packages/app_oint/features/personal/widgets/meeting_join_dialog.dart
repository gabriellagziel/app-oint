import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meeting_join_providers.dart';

class MeetingJoinDialog extends ConsumerStatefulWidget {
  final String meetingId;

  const MeetingJoinDialog({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingJoinDialog> createState() => _MeetingJoinDialogState();
}

class _MeetingJoinDialogState extends ConsumerState<MeetingJoinDialog> {
  bool _silentJoin = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Meeting'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Would you like to join this meeting?'),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _silentJoin,
                onChanged: (value) {
                  setState(() {
                    _silentJoin = value ?? false;
                  });
                },
              ),
              const Text('Join silently (don\'t notify others)'),
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
            try {
              await ref
                  .read(meetingJoinServiceProvider)
                  .joinMeeting(
                    meetingId: widget.meetingId,
                    silent: _silentJoin,
                  );
              if (context.mounted) {
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error joining meeting: $e')),
                );
              }
            }
          },
          child: const Text('Join'),
        ),
      ],
    );
  }
}
