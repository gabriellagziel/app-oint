import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meeting_action_service.dart';

final meetingActionServiceProvider = Provider((ref) => MeetingActionService());

final isMeetingCreatorProvider = FutureProvider.family<bool, String>((
  ref,
  meetingId,
) {
  final service = ref.watch(meetingActionServiceProvider);
  return service.isCreator(meetingId);
});
