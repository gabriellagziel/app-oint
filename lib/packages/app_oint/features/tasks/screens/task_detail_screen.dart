import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final svc = context.read<TaskService>();
    return FutureBuilder<Task?>(
      future: svc.get(id),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final t = snap.data;
        if (t == null)
          return const Scaffold(body: Center(child: Text('Task not found')));
        return Scaffold(
          appBar: AppBar(title: Text(t.title)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description:\n${t.description ?? '(none)'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
