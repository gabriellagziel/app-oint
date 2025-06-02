import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/providers/meeting_creation_provider.dart';
import 'package:app_oint9/utils/localizations_helper.dart';

/// Widget for the meeting title step
class MeetingStepTitle extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const MeetingStepTitle({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<MeetingStepTitle> createState() => _MeetingStepTitleState();
}

class _MeetingStepTitleState extends ConsumerState<MeetingStepTitle> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitTitle() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(meetingCreationProvider.notifier)
          .updateTitle(_titleController.text);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocalizationsHelper.getString(context, 'meeting_title_step'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: LocalizationsHelper.getString(
                      context, 'meeting_title_label'),
                  hintText: LocalizationsHelper.getString(
                      context, 'meeting_title_hint'),
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitTitle(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationsHelper.getString(
                        context, 'meeting_title_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitTitle,
                  child: Text(LocalizationsHelper.getString(
                      context, 'meeting_title_continue')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
