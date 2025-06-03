import 'package:flutter/material.dart';

/// Widget for selecting meeting date and time
class MeetingStepDateTime extends StatelessWidget {
  final DateTime? initialDateTime;
  final void Function(DateTime) onDateTimePicked;

  const MeetingStepDateTime({
    Key? key,
    this.initialDateTime,
    required this.onDateTimePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: initialDateTime ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null && context.mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null && context.mounted) {
                onDateTimePicked(DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ));
              }
            }
          },
          child: const Text('Select Date & Time'),
        ),
        if (initialDateTime != null)
          Text('Selected: ${initialDateTime.toString()}'),
      ],
    );
  }
}
