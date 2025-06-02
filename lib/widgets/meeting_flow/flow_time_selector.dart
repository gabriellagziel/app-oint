import 'package:flutter/material.dart';

class FlowTimeSelector extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onSelect;

  const FlowTimeSelector({
    super.key,
    this.selectedTime,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Selected: ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                onSelect(time);
              }
            },
            child: const Text('Select Time'),
          ),
        ],
      ),
    );
  }
}
