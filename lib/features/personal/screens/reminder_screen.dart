import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingRemindersAsync = ref.watch(pendingRemindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createReminder'),
        child: const Icon(Icons.add),
      ),
      body: upcomingRemindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (reminders) {
          final now = DateTime.now();
          final today =
              reminders
                  .where(
                    (r) =>
                        r.scheduledTime.year == now.year &&
                        r.scheduledTime.month == now.month &&
                        r.scheduledTime.day == now.day,
                  )
                  .toList();

          final thisWeek =
              reminders
                  .where(
                    (r) =>
                        r.scheduledTime.isAfter(now) &&
                        r.scheduledTime.difference(now).inDays <= 7 &&
                        !(r.scheduledTime.year == now.year &&
                            r.scheduledTime.month == now.month &&
                            r.scheduledTime.day == now.day),
                  )
                  .toList();

          final later =
              reminders
                  .where(
                    (r) => r.scheduledTime.isAfter(
                      now.add(const Duration(days: 7)),
                    ),
                  )
                  .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (today.isNotEmpty) ...[
                const Text(
                  'Today',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...today.map((r) => ReminderCard(reminder: r)),
                const SizedBox(height: 16),
              ],
              if (thisWeek.isNotEmpty) ...[
                const Text(
                  'This Week',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...thisWeek.map((r) => ReminderCard(reminder: r)),
                const SizedBox(height: 16),
              ],
              if (later.isNotEmpty) ...[
                const Text(
                  'Later',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...later.map((r) => ReminderCard(reminder: r)),
              ],
              if (reminders.isEmpty)
                const Center(child: Text('No upcoming reminders found.')),
            ],
          );
        },
      ),
    );
  }
}
