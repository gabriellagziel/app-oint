import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meeting.dart';
import '../../services/meeting_service.dart';
import '../../../utils/stream_extensions.dart';

class MeetingListScreen extends StatelessWidget {
  const MeetingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<MeetingService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Meetings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/meeting/create'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Meeting>>(
        stream: svc.collection.streamCollection(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text(snap.error.toString()));
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty)
            return const Center(child: Text('No meetings yet'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final m = items[i];
              return ListTile(
                title: Text(m.title),
                subtitle: Text('${m.start} → ${m.end}'),
                onTap: () => Navigator.of(context).pushNamed(
                  '/meeting/detail',
                  arguments: m.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
