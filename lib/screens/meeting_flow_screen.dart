import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meeting_draft.dart';
import '../models/appointment.dart';
import '../providers/appointments_service_provider.dart';
import '../utils/meeting_flow_steps.dart';
import '../widgets/meeting_flow/flow_message_bubble.dart';
import '../widgets/meeting_flow/flow_input_field.dart';
import '../widgets/meeting_flow/flow_option_selector.dart';
import '../widgets/meeting_flow/flow_date_selector.dart' as date;
import '../widgets/meeting_flow/flow_time_selector.dart' as time;
import '../widgets/meeting_step_participants.dart';
import '../utils/localizations_helper.dart';

final meetingDraftProvider =
    StateNotifierProvider<MeetingDraftNotifier, MeetingDraft>((ref) {
  return MeetingDraftNotifier();
});

class MeetingDraftNotifier extends StateNotifier<MeetingDraft> {
  MeetingDraftNotifier() : super(const MeetingDraft());

  void updateTitle(String title) {
    state = state.copyWith(title: title, currentStep: state.currentStep + 1);
  }

  void updateDateTime(DateTime datetime) {
    state =
        state.copyWith(datetime: datetime, currentStep: state.currentStep + 1);
  }

  void updateMeetingType(String type) {
    state =
        state.copyWith(meetingType: type, currentStep: state.currentStep + 1);
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

  void updateLocation(String location) {
    state =
        state.copyWith(location: location, currentStep: state.currentStep + 1);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes, currentStep: state.currentStep + 1);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    if (state.currentStep < MeetingFlowSteps.steps.length - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }
}

class MeetingFlowScreen extends ConsumerStatefulWidget {
  const MeetingFlowScreen({super.key});

  @override
  ConsumerState<MeetingFlowScreen> createState() => _MeetingFlowScreenState();
}

class _MeetingFlowScreenState extends ConsumerState<MeetingFlowScreen> {
  final _scrollController = ScrollController();
  bool _isCreatingMeeting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _createMeeting() async {
    final draft = ref.read(meetingDraftProvider);
    if (!draft.isComplete) return;

    setState(() => _isCreatingMeeting = true);

    try {
      final appointment = Appointment(
        id: '', // Will be set by Firestore
        title: draft.title,
        datetime: draft.datetime ?? DateTime.now(),
        location: draft.location,
        notes: draft.notes,
        participants: draft.participants,
        userId: '', // Will be set by the service
      );

      final appointmentsService = ref.read(appointmentsServiceProvider);
      final appointmentId =
          await appointmentsService.createAppointment(appointment);

      if (!mounted) return;

      // Navigate to confirmation screen
      Navigator.pushReplacementNamed(
        context,
        '/meeting-confirmation',
        arguments: appointmentId,
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${LocalizationsHelper.getString(context, 'meeting_creation_error')}: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: LocalizationsHelper.getString(
                context, 'meeting_creation_error_dismiss'),
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingMeeting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(meetingDraftProvider);
    final currentStep = MeetingFlowSteps.steps[draft.currentStep];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
        actions: [
          if (draft.isComplete)
            IconButton(
              icon: _isCreatingMeeting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: _isCreatingMeeting ? null : _createMeeting,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                // Show all previous steps
                for (var i = 0; i < draft.currentStep; i++)
                  _buildStepMessage(i, draft),

                // Show current step
                FlowMessageBubble(
                  message: currentStep.message,
                  isUser: false,
                ),
                const SizedBox(height: 16),
                _buildStepInput(currentStep),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepMessage(int stepIndex, MeetingDraft draft) {
    String message = '';

    switch (stepIndex) {
      case 0:
        message = draft.title;
        break;
      case 1:
      case 2:
        if (draft.datetime != null) {
          message =
              '${draft.datetime!.year}-${draft.datetime!.month.toString().padLeft(2, '0')}-${draft.datetime!.day.toString().padLeft(2, '0')} '
              '${draft.datetime!.hour.toString().padLeft(2, '0')}:${draft.datetime!.minute.toString().padLeft(2, '0')}';
        }
        break;
      case 3:
        message = draft.meetingType;
        break;
      case 4:
        message = draft.participants.join(', ');
        break;
      case 5:
        message = draft.location;
        break;
    }

    return FlowMessageBubble(
      message: message,
      isUser: true,
    );
  }

  Widget _buildStepInput(MeetingFlowStep step) {
    final draft = ref.watch(meetingDraftProvider);
    if (step.isDatePicker) {
      return date.FlowDateSelector(
        selectedDate: draft.datetime,
        onSelect: (date) {
          ref.read(meetingDraftProvider.notifier).updateDateTime(date);
          _scrollToBottom();
        },
      );
    } else if (step.isTimePicker) {
      return time.FlowTimeSelector(
        selectedTime: draft.datetime != null
            ? TimeOfDay.fromDateTime(draft.datetime!)
            : null,
        onSelect: (time) {
          final date = draft.datetime ?? DateTime.now();
          final newDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          ref.read(meetingDraftProvider.notifier).updateDateTime(newDate);
          _scrollToBottom();
        },
      );
    } else if (step.options != null) {
      return FlowOptionSelector(
        options: step.options!,
        selectedOption: draft.meetingType,
        onSelect: (option) {
          ref.read(meetingDraftProvider.notifier).updateMeetingType(option);
          _scrollToBottom();
        },
      );
    } else if (step.isContactPicker) {
      return MeetingStepParticipants(
        onComplete: () {
          ref.read(meetingDraftProvider.notifier).nextStep();
        },
      );
    } else {
      return FlowInputField(
        hintText: step.hint ?? '',
        onSubmit: (value) {
          if (step.isOptional && value.isEmpty) {
            ref.read(meetingDraftProvider.notifier).nextStep();
          } else if (draft.currentStep == 0) {
            ref.read(meetingDraftProvider.notifier).updateTitle(value);
          } else {
            ref.read(meetingDraftProvider.notifier).updateLocation(value);
          }
          _scrollToBottom();
        },
      );
    }
  }
}
