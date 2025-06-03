import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meeting_chat_step.dart';

final meetingAnswersProvider = StateProvider<Map<String, String>>((ref) => {});

final meetingChatFlowControllerProvider =
    StateNotifierProvider<MeetingChatFlowController, List<MeetingChatStep>>((
      ref,
    ) {
      return MeetingChatFlowController();
    });

class MeetingChatFlowController extends StateNotifier<List<MeetingChatStep>> {
  MeetingChatFlowController() : super(_initialFlow({}));

  static List<MeetingChatStep> _initialFlow(Map<String, String> answers) {
    final allSteps = <MeetingChatStep>[
      MeetingChatStep(
        id: "step_what_to_do",
        type: ChatStepType.options,
        promptKey: "chat.what_do_you_want",
        options: [
          "chat.option_schedule_meeting",
          "chat.option_reminder",
          "chat.option_with_business",
          "chat.option_note_event",
        ],
      ),
      MeetingChatStep(
        id: "step_select_participant",
        type: ChatStepType.input,
        promptKey: "chat.who_is_it_with",
        visibleIfStepEquals: "step_what_to_do=chat.option_schedule_meeting",
      ),
      MeetingChatStep(
        id: "step_pick_datetime",
        type: ChatStepType.dateTime,
        promptKey: "chat.when_is_it",
      ),
      MeetingChatStep(
        id: "step_location_type",
        type: ChatStepType.options,
        promptKey: "chat.where_will_it_be",
        options: [
          "chat.option_virtual",
          "chat.option_in_person",
          "chat.option_phone",
        ],
        visibleIfStepEquals: "step_what_to_do=chat.option_schedule_meeting",
      ),
      MeetingChatStep(
        id: "step_business_details",
        type: ChatStepType.input,
        promptKey: "chat.business_name",
        visibleIfStepEquals: "step_what_to_do=chat.option_with_business",
      ),
      MeetingChatStep(
        id: "step_reminder_type",
        type: ChatStepType.options,
        promptKey: "chat.reminder_type",
        options: [
          "chat.option_daily",
          "chat.option_weekly",
          "chat.option_monthly",
        ],
        visibleIfStepEquals: "step_what_to_do=chat.option_reminder",
      ),
      MeetingChatStep(
        id: "step_add_notes",
        type: ChatStepType.input,
        promptKey: "chat.any_notes",
        optional: true,
      ),
      MeetingChatStep(
        id: "step_confirm",
        type: ChatStepType.confirm,
        promptKey: "chat.review_and_confirm",
      ),
    ];

    return allSteps.where((step) {
      if (step.visibleIfStepEquals == null) return true;

      final [stepId, expectedValue] = step.visibleIfStepEquals!.split('=');
      final actualValue = answers[stepId];

      return actualValue == expectedValue;
    }).toList();
  }

  bool isFlowComplete(Map<String, String> answers) {
    final visibleSteps = _initialFlow(answers);
    return visibleSteps.every((step) {
      if (step.optional) return true;
      return answers.containsKey(step.id);
    });
  }

  void addDynamicStep(MeetingChatStep step) {
    state = [...state, step];
  }

  void resetFlow() {
    state = _initialFlow({});
  }

  void removeStep(String stepId) {
    state = state.where((step) => step.id != stepId).toList();
  }

  void updateStep(MeetingChatStep updatedStep) {
    state =
        state
            .map((step) => step.id == updatedStep.id ? updatedStep : step)
            .toList();
  }

  bool isStepVisible(MeetingChatStep step, Map<String, String> answers) {
    if (step.visibleIfStepEquals == null) return true;

    final [stepId, expectedValue] = step.visibleIfStepEquals!.split('=');
    return answers[stepId] == expectedValue;
  }

  void submitAnswer(String stepId, String answer, WidgetRef ref) {
    final current = Map<String, String>.from(ref.read(meetingAnswersProvider));
    current[stepId] = answer;
    ref.read(meetingAnswersProvider.notifier).state = current;

    // Rebuild visible flow based on new answers
    state = _initialFlow(current);
  }

  String? getAnswer(String stepId, WidgetRef ref) {
    return ref.read(meetingAnswersProvider)[stepId];
  }

  void clearAnswerAndReflow(String stepId, WidgetRef ref) {
    final current = Map<String, String>.from(ref.read(meetingAnswersProvider));
    current.remove(stepId);

    // Remove all downstream answers (steps after this one)
    final currentSteps = _initialFlow(current);
    final clearedKeys = current.keys.where((k) {
      final indexOfCleared = currentSteps.indexWhere((s) => s.id == stepId);
      final indexOfKey = currentSteps.indexWhere((s) => s.id == k);
      return indexOfKey > indexOfCleared;
    });

    for (final key in clearedKeys) {
      current.remove(key);
    }

    ref.read(meetingAnswersProvider.notifier).state = current;
    state = _initialFlow(current);
  }
}
