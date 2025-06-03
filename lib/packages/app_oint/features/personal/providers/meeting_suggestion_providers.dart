import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meeting_suggestion_service.dart';

final meetingSuggestionServiceProvider = Provider(
  (ref) => MeetingSuggestionService(),
);

final meetingSuggestionProvider = FutureProvider.family<bool, String>((
  ref,
  meetingId,
) {
  final service = ref.watch(meetingSuggestionServiceProvider);
  return service.shouldShowSuggestion(meetingId);
});
