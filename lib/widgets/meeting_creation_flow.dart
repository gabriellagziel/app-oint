import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/meeting_draft.dart';
import 'meeting_step_datetime.dart';
import 'meeting_step_type.dart';
import 'meeting_step_location.dart';
import 'meeting_step_notes.dart';

class MeetingCreationFlowWidget extends StatefulWidget {
  const MeetingCreationFlowWidget({Key? key, required this.onComplete})
      : super(key: key);

  final void Function(MeetingDraft) onComplete;

  @override
  State<MeetingCreationFlowWidget> createState() =>
      _MeetingCreationFlowWidgetState();
}

class _MeetingCreationFlowWidgetState extends State<MeetingCreationFlowWidget> {
  DateTime? _selectedDateTime;
  String? _selectedType;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _currentStep = 0;

  void _goNext() => setState(() => _currentStep++);
  void _goBack() => setState(() => _currentStep--);

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _currentStep < 4 ? _goNext : null,
      onStepCancel: _currentStep > 0 ? _goBack : null,
      onStepTapped: (i) => setState(() => _currentStep = i),
      steps: [
        Step(
          title: const Text('Date & Time'),
          content: MeetingStepDateTime(
            initialDateTime: _selectedDateTime,
            onDateTimePicked: (d) {
              setState(() => _selectedDateTime = d);
              _goNext();
            },
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Type'),
          content: MeetingStepType(
            initialMeetingType: _selectedType,
            onTypeSelected: (t) {
              setState(() => _selectedType = t);
              _goNext();
            },
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Location'),
          content: MeetingStepLocation(
            locationController: _locationController,
            onLocationSelected: (loc) {
              _locationController.text = loc;
              _goNext();
            },
          ),
          isActive: _currentStep >= 2,
        ),
        Step(
          title: const Text('Notes'),
          content: MeetingStepNotes(
            notesController: _notesController,
            onNotesSaved: (text) {
              _notesController.text = text;
              _goNext();
            },
          ),
          isActive: _currentStep >= 3,
        ),
        Step(
          title: const Text('Done'),
          content: ElevatedButton(
            onPressed: () {
              final draft = MeetingDraft(
                uuid: const Uuid().v4(),
                datetime: _selectedDateTime!,
                meetingType: _selectedType!,
                location: _locationController.text,
                notes: _notesController.text,
              );
              widget.onComplete(draft);
            },
            child: const Text('Finish'),
          ),
          isActive: _currentStep >= 4,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
