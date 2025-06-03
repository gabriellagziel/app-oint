import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/meeting_type.dart';
import '../models/meeting_location.dart';

part 'meeting_creation_provider.freezed.dart';

@freezed
class MeetingCreationState with _$MeetingCreationState {
  const factory MeetingCreationState({
    @Default(0) int currentStep,
    @Default(false) bool isComplete,
    @Default('') String title,
    MeetingType? type,
    DateTime? dateTime,
    @Default([]) List<String> participants,
    MeetingLocation? location,
    @Default('') String notes,
  }) = _MeetingCreationState;
}

class MeetingCreationNotifier extends StateNotifier<MeetingCreationState> {
  MeetingCreationNotifier() : super(const MeetingCreationState());

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateType(MeetingType type) {
    state = state.copyWith(type: type);
  }

  void updateDate(DateTime dateTime) {
    state = state.copyWith(dateTime: dateTime);
  }

  void updateParticipants(List<String> participants) {
    state = state.copyWith(participants: participants);
  }

  void addParticipant(String participant) {
    final participants = List<String>.from(state.participants)
      ..add(participant);
    state = state.copyWith(participants: participants);
  }

  void removeParticipant(String participant) {
    final participants = List<String>.from(state.participants)
      ..remove(participant);
    state = state.copyWith(participants: participants);
  }

  void updateLocation(MeetingLocation location) {
    state = state.copyWith(location: location);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }

  void reset() {
    state = const MeetingCreationState();
  }

  void submit() {
    if (_isValid()) {
      state = state.copyWith(isComplete: true);
    }
  }

  bool _isValid() {
    return state.type != null &&
        state.dateTime != null &&
        state.participants.isNotEmpty &&
        state.location != null;
  }
}

final meetingCreationProvider =
    StateNotifierProvider<MeetingCreationNotifier, MeetingCreationState>(
  (ref) => MeetingCreationNotifier(),
);
