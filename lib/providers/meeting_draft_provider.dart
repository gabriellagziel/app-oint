import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/meeting_draft.dart';

final meetingDraftProvider =
    StateNotifierProvider<MeetingDraftNotifier, MeetingDraft?>((ref) {
  return MeetingDraftNotifier();
});

class MeetingDraftNotifier extends StateNotifier<MeetingDraft?> {
  MeetingDraftNotifier() : super(null);

  void createNewDraft() {
    state = MeetingDraft(
      uuid: const Uuid().v4(),
      datetime: DateTime.now(),
      meetingType: '',
      location: '',
      notes: '',
    );
  }

  void updateDraft(MeetingDraft draft) {
    state = draft;
  }

  void clearDraft() {
    state = null;
  }

  void updateDateTime(DateTime datetime) {
    if (state != null) {
      state = state!.copyWith(datetime: datetime);
    }
  }

  void updateLocation(String location) {
    if (state != null) {
      state = state!.copyWith(location: location);
    }
  }

  void updateMeetingType(String type) {
    if (state != null) {
      state = state!.copyWith(meetingType: type);
    }
  }

  void updateNotes(String notes) {
    if (state != null) {
      state = state!.copyWith(notes: notes);
    }
  }
}
