import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../l10n/l10n_ext.dart';
import '../../auth/providers/auth_provider.dart';
import '../controllers/meeting_chat_flow_controller.dart';
import '../models/meeting_chat_step.dart';
import '../services/meeting_chat_memory_service.dart';

class MeetingCreationChatScreen extends ConsumerStatefulWidget {
  const MeetingCreationChatScreen({super.key});

  @override
  ConsumerState<MeetingCreationChatScreen> createState() =>
      _MeetingCreationChatScreenState();
}

class _MeetingCreationChatScreenState
    extends ConsumerState<MeetingCreationChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<MeetingChatStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _steps = ref.read(meetingChatFlowControllerProvider);

    // Listen for flow changes to handle animations
    ref.listen(meetingChatFlowControllerProvider, (previous, next) {
      if (previous == null) return;

      // Find newly added steps
      for (var i = 0; i < next.length; i++) {
        if (i >= previous.length || next[i].id != previous[i].id) {
          _listKey.currentState?.insertItem(i);
        }
      }

      // Find removed steps
      for (var i = 0; i < previous.length; i++) {
        if (i >= next.length || previous[i].id != next[i].id) {
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: FadeTransition(
                opacity: animation,
                child: _buildChatStep(previous[i]),
              ),
            ),
          );
        }
      }

      _steps = next;
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleAnswer(String stepId, String answer) {
    // Save to memory service
    final currentUser = ref.read(currentUserProvider).value;
    ref
        .read(meetingChatMemoryServiceProvider)
        .saveChoice(currentUser?.id ?? 'anonymous', stepId, answer);

    // Update flow controller
    ref
        .read(meetingChatFlowControllerProvider.notifier)
        .submitAnswer(stepId, answer, ref);

    // Clear input if it was used
    if (_inputController.text.isNotEmpty) {
      _inputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ref.watch(meetingChatFlowControllerProvider);
    final answers = ref.watch(meetingAnswersProvider);
    final currentStep = steps.isNotEmpty ? steps.last : null;
    final showInput = currentStep?.type == ChatStepType.input;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chatWhatDoYouWant),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(meetingChatFlowControllerProvider.notifier).resetFlow();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              padding: const EdgeInsets.all(16),
              initialItemCount: steps.length,
              itemBuilder: (context, index, animation) {
                final step = steps[index];
                final answer = answers[step.id];
                final stepKey = GlobalKey();

                return SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChatStep(step),
                        if (answer != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              key: stepKey,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      answer,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    onPressed: () {
                                      ref
                                          .read(
                                            meetingChatFlowControllerProvider
                                                .notifier,
                                          )
                                          .clearAnswerAndReflow(step.id, ref);

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (stepKey.currentContext != null) {
                                          Scrollable.ensureVisible(
                                            stepKey.currentContext!,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            alignment: 0.5,
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (showInput) _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildChatStep(MeetingChatStep step) {
    switch (step.type) {
      case ChatStepType.options:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.chatWhatDoYouWant,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: step.options?.map((option) {
                    return ElevatedButton(
                      onPressed: () => _handleAnswer(step.id, option),
                      child: Text(context.l10n.chatOptionScheduleMeeting),
                    );
                  }).toList() ??
                  [],
            ),
          ],
        );

      case ChatStepType.input:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.promptKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
          ],
        );

      case ChatStepType.dateTime:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.promptKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && context.mounted) {
                        _handleAnswer(step.id, date.toIso8601String());
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(context.l10n.chatSelectDate),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        if (!mounted) return;
                        _handleAnswer(step.id, time.format(context));
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(context.l10n.chatSelectTime),
                  ),
                ),
              ],
            ),
          ],
        );

      case ChatStepType.confirm:
        final answers = ref.watch(meetingAnswersProvider);
        final isComplete = ref
            .read(meetingChatFlowControllerProvider.notifier)
            .isFlowComplete(answers);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.promptKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (isComplete) ...[
              _buildSummaryCard(answers),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: Text(context.l10n.chatFinishButton),
                onPressed: () => _submitToFirestore(context),
              ),
            ] else
              Text(
                context.l10n.chatCompleteRequired,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSummaryCard(Map<String, String> answers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.chatSummaryTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context.l10n.chatSummaryType,
              answers['step_what_to_do'] ?? '',
            ),
            if (answers.containsKey('step_select_participant'))
              _buildSummaryRow(
                context.l10n.chatSummaryWith,
                answers['step_select_participant']!,
              ),
            if (answers.containsKey('step_pick_datetime'))
              _buildSummaryRow(
                context.l10n.chatSummaryWhen,
                answers['step_pick_datetime']!,
              ),
            if (answers.containsKey('step_location_type'))
              _buildSummaryRow(
                context.l10n.chatSummaryWhere,
                answers['step_location_type']!,
              ),
            if (answers.containsKey('step_business_details'))
              _buildSummaryRow(
                context.l10n.chatSummaryBusiness,
                answers['step_business_details']!,
              ),
            if (answers.containsKey('step_reminder_type'))
              _buildSummaryRow(
                context.l10n.chatSummaryReminder,
                answers['step_reminder_type']!,
              ),
            if (answers.containsKey('step_add_notes'))
              _buildSummaryRow(
                  context.l10n.chatSummaryNotes, answers['step_add_notes']!),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _submitToFirestore(BuildContext context) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chatSignInRequired)),
      );
      return;
    }

    final answers = ref.read(meetingAnswersProvider);
    final meetingData = {
      'creatorId': user.id,
      'createdAt': FieldValue.serverTimestamp(),
      'type': answers['step_what_to_do'],
      'participant': answers['step_select_participant'],
      'notes': answers['step_add_notes'],
      'datetime': answers['step_pick_datetime'],
      'location': answers['step_location_type'],
      'businessDetails': answers['step_business_details'],
      'reminderType': answers['step_reminder_type'],
      'status': 'pending',
    };

    try {
      await FirebaseFirestore.instance.collection('meetings').add(meetingData);

      // Clear the flow and answers
      ref.read(meetingChatFlowControllerProvider.notifier).resetFlow();
      ref.read(meetingAnswersProvider.notifier).state = {};

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chatSuccessMessage)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chatErrorMessage)),
      );
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: context.l10n.chatTypeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  final currentStep = _steps.last;
                  _handleAnswer(currentStep.id, value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_inputController.text.isNotEmpty) {
                final currentStep = _steps.last;
                _handleAnswer(currentStep.id, _inputController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
