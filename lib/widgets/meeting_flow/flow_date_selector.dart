import 'package:flutter/material.dart';

class FlowDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onSelect;

  const FlowDateSelector({
    super.key,
    this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Selected: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                onSelect(date);
              }
            },
            child: const Text('Select Date'),
          ),
        ],
      ),
    );
  }
}
