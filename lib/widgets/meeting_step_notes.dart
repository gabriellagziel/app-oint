import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/providers/meeting_creation_provider.dart';
import 'package:app_oint9/utils/localizations_helper.dart';

/// Widget for entering meeting notes
class MeetingStepNotes extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const MeetingStepNotes({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<MeetingStepNotes> createState() => _MeetingStepNotesState();
}

class _MeetingStepNotesState extends ConsumerState<MeetingStepNotes> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitNotes() {
    ref
        .read(meetingCreationProvider.notifier)
        .updateNotes(_notesController.text);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocalizationsHelper.getString(context, 'meeting_notes_step'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: LocalizationsHelper.getString(
                    context, 'meeting_notes_label'),
                hintText: LocalizationsHelper.getString(
                    context, 'meeting_notes_hint'),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitNotes,
                child: Text(LocalizationsHelper.getString(
                    context, 'meeting_notes_continue')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
