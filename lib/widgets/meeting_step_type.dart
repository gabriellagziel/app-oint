import 'package:flutter/material.dart';

class MeetingStepType extends StatelessWidget {
  final String? initialMeetingType;
  final void Function(String) onTypeSelected;

  const MeetingStepType({
    Key? key,
    this.initialMeetingType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: initialMeetingType,
          hint: const Text('Select meeting type'),
          items: ['One-on-One', 'Group', 'Conference']
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onTypeSelected(value);
            }
          },
        ),
      ],
    );
  }
}
