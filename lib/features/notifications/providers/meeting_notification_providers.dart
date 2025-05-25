import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meeting_notification_service.dart';

final meetingNotificationServiceProvider = Provider<MeetingNotificationService>(
  (ref) => MeetingNotificationService(),
);
