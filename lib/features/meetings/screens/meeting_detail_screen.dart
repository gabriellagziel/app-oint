import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meeting.dart';
import '../../services/meeting_service.dart';

class MeetingDetailScreen extends StatelessWidget {
  const MeetingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final svc = context.read<MeetingService>();
    return FutureBuilder<Meeting?>(
      future: svc.get(id),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final m = snap.data;
        if (m == null)
          return const Scaffold(body: Center(child: Text('Meeting not found')));
        return Scaffold(
          appBar: AppBar(title: Text(m.title)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description:\n${m.description ?? '(none)'}'),
                const SizedBox(height: 16),
                Text('Date: ${m.date.toLocal()}'),
                const SizedBox(height: 16),
                Text('Duration: ${m.duration.inMinutes} minutes'),
              ],
            ),
          ),
        );
      },
    );
  }
}
