import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../../utils/stream_extensions.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.read<TaskService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/task/create'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Task>>(
        stream: svc.collection.streamCollection(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text(snap.error.toString()));
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const Center(child: Text('No tasks yet'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final t = items[i];
              return ListTile(
                title: Text(t.title),
                subtitle: Text(t.description ?? ''),
                onTap: () => Navigator.of(context)
                    .pushNamed('/task/detail', arguments: t.id),
              );
            },
          );
        },
      ),
    );
  }
}
