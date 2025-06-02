import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meeting_draft.dart';
import '../models/appointment.dart';
import '../services/appointments_service.dart';
import '../services/contact_picker_service.dart';
import '../providers/appointments_service_provider.dart';
import '../providers/contact_picker_service_provider.dart';

/// Provider for managing the meeting creation flow state
final meetingCreationProvider =
    StateNotifierProvider<MeetingCreationNotifier, MeetingDraft>((ref) {
  return MeetingCreationNotifier(
    appointmentsService: ref.watch(appointmentsServiceProvider),
    contactPickerService: ref.watch(contactPickerServiceProvider),
  );
});

/// Notifier class for managing meeting creation state
class MeetingCreationNotifier extends StateNotifier<MeetingDraft> {
  final AppointmentsService appointmentsService;
  final ContactPickerService contactPickerService;

  MeetingCreationNotifier({
    required this.appointmentsService,
    required this.contactPickerService,
  }) : super(const MeetingDraft());

  /// Updates the meeting title
  void updateTitle(String title) {
    state = state.copyWith(
      title: title,
      currentStep: state.nextStep,
    );
  }

  /// Updates the meeting date and time
  void updateDateTime(DateTime datetime) {
    state = state.copyWith(
      datetime: datetime,
      currentStep: state.nextStep,
    );
  }

  /// Updates the meeting type
  void updateMeetingType(String type) {
    state = state.copyWith(
      meetingType: type,
      currentStep: state.nextStep,
    );
  }

  /// Adds a participant to the meeting
  void addParticipant(String participant) {
    final participants = List<String>.from(state.participants)
      ..add(participant);
    state = state.copyWith(participants: participants);
  }

  /// Removes a participant from the meeting
  void removeParticipant(String participant) {
    final participants = List<String>.from(state.participants)
      ..remove(participant);
    state = state.copyWith(participants: participants);
  }

  /// Updates the meeting location
  void updateLocation(String location) {
    state = state.copyWith(
      location: location,
      currentStep: state.nextStep,
    );
  }

  /// Updates the meeting notes
  void updateNotes(String notes) {
    state = state.copyWith(
      notes: notes,
      currentStep: state.nextStep,
    );
  }

  /// Updates the meeting image URL
  void updateImageUrl(String imageUrl) {
    state = state.copyWith(imageUrl: imageUrl);
  }

  /// Moves to a specific step in the flow
  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Moves to the next step if available
  void nextStep() {
    if (state.hasNextStep) {
      state = state.copyWith(currentStep: state.nextStep);
    }
  }

  /// Moves to the previous step if available
  void previousStep() {
    if (state.hasPreviousStep) {
      state = state.copyWith(currentStep: state.previousStep);
    }
  }

  /// Resets the meeting draft to initial state
  void reset() {
    state = const MeetingDraft();
  }

  /// Submits the meeting draft and creates the appointment
  Future<String> submit() async {
    if (!state.isValid) {
      throw Exception('Meeting draft is not valid');
    }

    final appointment = Appointment(
      id: '', // Will be set by Firestore
      title: state.title,
      datetime: state.datetime ?? DateTime.now(),
      location: state.location,
      notes: state.notes,
      participants: state.participants,
      userId: '', // Will be set by the service
    );

    final appointmentId =
        await appointmentsService.createAppointment(appointment);
    state = state.copyWith(isComplete: true);
    return appointmentId;
  }
}
