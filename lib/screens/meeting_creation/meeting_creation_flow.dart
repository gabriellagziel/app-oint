import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/providers/meeting_creation_provider.dart';
import 'package:app_oint9/widgets/meeting_step_title.dart';
import 'package:app_oint9/widgets/meeting_step_datetime.dart';
import 'package:app_oint9/widgets/meeting_step_type.dart';
import 'package:app_oint9/widgets/meeting_step_participants.dart';
import 'package:app_oint9/widgets/meeting_step_location.dart';
import 'package:app_oint9/widgets/meeting_step_notes.dart';
import 'package:app_oint9/utils/localizations_helper.dart';
import 'package:app_oint9/models/meeting_draft.dart';

/// The main screen for creating a new meeting
class MeetingCreationFlow extends ConsumerStatefulWidget {
  const MeetingCreationFlow({super.key});

  @override
  ConsumerState<MeetingCreationFlow> createState() =>
      _MeetingCreationFlowState();
}

class _MeetingCreationFlowState extends ConsumerState<MeetingCreationFlow> {
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

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

  Future<void> _submitMeeting() async {
    setState(() => _isSubmitting = true);

    try {
      final appointmentId =
          await ref.read(meetingCreationProvider.notifier).submit();
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return MeetingStepTitle(
          onComplete: () {
            ref.read(meetingCreationProvider.notifier).nextStep();
            _scrollToBottom();
          },
        );
      case 1:
        return MeetingStepDateTime(
          onComplete: () {
            ref.read(meetingCreationProvider.notifier).nextStep();
            _scrollToBottom();
          },
        );
      case 2:
        return MeetingStepType(
          onComplete: () {
            ref.read(meetingCreationProvider.notifier).nextStep();
            _scrollToBottom();
          },
        );
      case 3:
        return MeetingStepParticipants(
          onComplete: () {
            ref.read(meetingCreationProvider.notifier).nextStep();
            _scrollToBottom();
          },
        );
      case 4:
        return MeetingStepLocation(
          onComplete: () {
            ref.read(meetingCreationProvider.notifier).nextStep();
            _scrollToBottom();
          },
        );
      case 5:
        return MeetingStepNotes(
          onComplete: () {
            ref.read(meetingCreationProvider.notifier).nextStep();
            _scrollToBottom();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(meetingCreationProvider);
    final isLastStep = draft.currentStep == 5;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationsHelper.getString(context, 'create_meeting')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: draft.hasPreviousStep
              ? () {
                  ref.read(meetingCreationProvider.notifier).previousStep();
                  _scrollToBottom();
                }
              : null,
        ),
        actions: [
          if (isLastStep)
            IconButton(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: _isSubmitting ? null : _submitMeeting,
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (draft.currentStep + 1) / 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          // Step content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Show all previous steps
                for (var i = 0; i < draft.currentStep; i++)
                  _buildStepContent(i),
                // Show current step
                _buildStepContent(draft.currentStep),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
