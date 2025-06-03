import 'package:flutter/material.dart';
import '../../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;

  const ReminderCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(reminder.title),
        subtitle: Text(reminder.description),
        trailing:
            reminder.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.radio_button_unchecked),
      ),
    );
  }
}
