import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reminder.dart';
import '../services/reminder_service.dart';

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService(),
);

final upcomingRemindersProvider = StreamProvider<List<Reminder>>((ref) {
  final service = ref.watch(reminderServiceProvider);
  return service.watchUpcomingReminders();
});

final pendingRemindersProvider = StreamProvider.autoDispose<List<Reminder>>(
  (ref) => ref.watch(reminderServiceProvider).getPendingRemindersStream(),
);

final completedRemindersProvider = StreamProvider.autoDispose<List<Reminder>>(
  (ref) => ref.watch(reminderServiceProvider).getCompletedRemindersStream(),
);
