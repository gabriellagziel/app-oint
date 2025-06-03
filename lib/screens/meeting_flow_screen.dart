import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/meeting_draft.dart';
import '../providers/meeting_draft_provider.dart';
import '../widgets/meeting_step_datetime.dart';
import '../widgets/meeting_step_type.dart';
import '../widgets/meeting_step_location.dart';
import '../widgets/meeting_step_notes.dart';

class MeetingFlowScreen extends ConsumerStatefulWidget {
  const MeetingFlowScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MeetingFlowScreen> createState() => _MeetingFlowScreenState();
}

class _MeetingFlowScreenState extends ConsumerState<MeetingFlowScreen> {
  DateTime? _selectedDateTime;
  String? _selectedType;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _currentStep = 0;

  void _goToNextStep() => setState(() => _currentStep = _currentStep + 1);
  void _goToPreviousStep() => setState(() => _currentStep = _currentStep - 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Meeting')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep < 4 ? _goToNextStep : null,
        onStepCancel: _currentStep > 0 ? _goToPreviousStep : null,
        onStepTapped: (index) => setState(() => _currentStep = index),
        steps: [
          Step(
            title: const Text('Pick Date & Time'),
            content: MeetingStepDateTime(
              initialDateTime: _selectedDateTime,
              onDateTimePicked: (picked) {
                setState(() => _selectedDateTime = picked);
                _goToNextStep();
              },
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Select Meeting Type'),
            content: MeetingStepType(
              initialMeetingType: _selectedType,
              onTypeSelected: (type) {
                setState(() => _selectedType = type);
                _goToNextStep();
              },
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Choose Location'),
            content: MeetingStepLocation(
              locationController: _locationController,
              onLocationSelected: (loc) {
                _locationController.text = loc;
                _goToNextStep();
              },
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Add Notes'),
            content: MeetingStepNotes(
              notesController: _notesController,
              onNotesSaved: (text) {
                _notesController.text = text;
                _goToNextStep();
              },
            ),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Confirm & Submit'),
            content: ElevatedButton(
              onPressed: () {
                final draft = MeetingDraft(
                  uuid: const Uuid().v4(),
                  datetime: _selectedDateTime!,
                  meetingType: _selectedType!,
                  location: _locationController.text,
                  notes: _notesController.text,
                );
                ref.read(meetingDraftProvider.notifier).updateDraft(draft);
                Navigator.of(context).pop();
              },
              child: const Text('Review & Confirm'),
            ),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
