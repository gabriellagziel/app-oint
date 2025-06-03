import 'package:flutter/material.dart';

/// Widget for entering meeting notes
class MeetingStepNotes extends StatelessWidget {
  final TextEditingController notesController;
  final void Function(String) onNotesSaved;

  const MeetingStepNotes({
    Key? key,
    required this.notesController,
    required this.onNotesSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: notesController,
      decoration: const InputDecoration(
        labelText: 'Meeting Notes',
        hintText: 'Add any additional notes',
      ),
      maxLines: 3,
      onSubmitted: onNotesSaved,
    );
  }
}
