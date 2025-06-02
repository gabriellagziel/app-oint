import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_oint9/providers/meeting_creation_provider.dart';
import 'package:app_oint9/utils/localizations_helper.dart';

/// Widget for entering meeting location
class MeetingStepLocation extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const MeetingStepLocation({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<MeetingStepLocation> createState() =>
      _MeetingStepLocationState();
}

class _MeetingStepLocationState extends ConsumerState<MeetingStepLocation> {
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _submitLocation() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(meetingCreationProvider.notifier)
          .updateLocation(_locationController.text);
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
                LocalizationsHelper.getString(context, 'meeting_location_step'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: LocalizationsHelper.getString(
                      context, 'meeting_location_label'),
                  hintText: LocalizationsHelper.getString(
                      context, 'meeting_location_hint'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitLocation(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocalizationsHelper.getString(
                        context, 'meeting_location_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitLocation,
                  child: Text(LocalizationsHelper.getString(
                      context, 'meeting_location_continue')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
