import 'package:flutter/material.dart';
import 'features/meetings/screens/meeting_creation_chat_screen.dart';
import 'features/meetings/screens/meeting_list_screen.dart';
import 'features/meetings/screens/meeting_detail_screen.dart';
import 'features/reminders/screens/reminder_creation_screen.dart';
import 'features/reminders/screens/reminder_list_screen.dart';
import 'features/reminders/screens/reminder_detail_screen.dart';
import 'features/tasks/screens/task_creation_screen.dart';
import 'features/tasks/screens/task_list_screen.dart';
import 'features/tasks/screens/task_detail_screen.dart';

final routes = <String, WidgetBuilder>{
  '/meeting/create': (ctx) => const MeetingCreationChatScreen(),
  '/meeting/list': (ctx) => const MeetingListScreen(),
  '/meeting/detail': (ctx) => const MeetingDetailScreen(),
  '/reminder/create': (ctx) => const ReminderCreationScreen(),
  '/reminder/list': (ctx) => const ReminderListScreen(),
  '/reminder/detail': (ctx) => const ReminderDetailScreen(),
  '/task/create': (ctx) => const TaskCreationScreen(),
  '/task/list': (ctx) => const TaskListScreen(),
  '/task/detail': (ctx) => const TaskDetailScreen(),
};
