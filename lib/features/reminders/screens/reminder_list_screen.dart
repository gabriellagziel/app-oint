import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reminder.dart';
import '../../services/reminder_service.dart';
import '../../../utils/stream_extensions.dart';

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<ReminderService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/reminder/create'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Reminder>>(
        stream: svc.collection.streamCollection(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text(snap.error.toString()));
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty)
            return const Center(child: Text('No reminders yet'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final r = items[i];
              return ListTile(
                leading: Icon(
                    r.done ? Icons.check_box : Icons.check_box_outline_blank),
                title: Text(r.title),
                onTap: () => Navigator.of(context)
                    .pushNamed('/reminder/detail', arguments: r.id),
              );
            },
          );
        },
      ),
    );
  }
}
