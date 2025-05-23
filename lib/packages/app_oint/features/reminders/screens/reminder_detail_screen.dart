import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reminder.dart';
import '../../services/reminder_service.dart';

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final svc = context.read<ReminderService>();
    return FutureBuilder<Reminder?>(
      future: svc.get(id),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final r = snap.data;
        if (r == null)
          return const Scaffold(
              body: Center(child: Text('Reminder not found')));
        return Scaffold(
          appBar: AppBar(title: Text(r.title)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due: ${r.due}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(r.done ? 'Status: Done' : 'Status: Pending'),
              ],
            ),
          ),
        );
      },
    );
  }
}
