import 'package:flutter/material.dart';

class FlowOptionSelector extends StatelessWidget {
  final List<String> options;
  final void Function(String) onSelect;
  final String? selectedOption;

  const FlowOptionSelector({
    super.key,
    required this.options,
    required this.onSelect,
    this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onSelect(option);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class FlowDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime) onSelect;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const FlowDateSelector({
    super.key,
    this.selectedDate,
    required this.onSelect,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: firstDate ?? DateTime.now(),
            lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            onSelect(date);
          }
        },
        icon: const Icon(Icons.calendar_today),
        label: Text(
          selectedDate != null
              ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
              : 'Select Date',
        ),
      ),
    );
  }
}

class FlowTimeSelector extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final void Function(TimeOfDay) onSelect;

  const FlowTimeSelector({
    super.key,
    this.selectedTime,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? TimeOfDay.now(),
          );
          if (time != null) {
            onSelect(time);
          }
        },
        icon: const Icon(Icons.access_time),
        label: Text(
          selectedTime != null
              ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
              : 'Select Time',
        ),
      ),
    );
  }
}
