import 'package:flutter/material.dart';

/// Widget for entering meeting location
class MeetingStepLocation extends StatelessWidget {
  final TextEditingController locationController;
  final void Function(String) onLocationSelected;

  const MeetingStepLocation({
    Key? key,
    required this.locationController,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: locationController,
      decoration: const InputDecoration(
        labelText: 'Meeting Location',
        hintText: 'Enter meeting location or URL',
      ),
      onSubmitted: onLocationSelected,
    );
  }
}
