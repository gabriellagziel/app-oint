import 'package:flutter/material.dart';
import 'features/meetings/screens/meeting_creation_screen.dart';
import 'features/reminders/screens/reminder_creation_screen.dart';
import 'features/tasks/screens/task_creation_screen.dart';

final routes = <String, WidgetBuilder>{
  '/meeting/create': (_) => const MeetingCreationScreen(),
  '/reminder/create': (_) => const ReminderCreationScreen(),
  '/task/create': (_) => const TaskCreationScreen(),
};
