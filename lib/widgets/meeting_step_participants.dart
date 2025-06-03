import 'package:flutter/material.dart';
import '../models/contact.dart';

/// Widget for managing meeting participants
class MeetingStepParticipants extends StatelessWidget {
  final List<Contact> allContacts;
  final List<Contact> selectedContacts;
  final ValueChanged<List<Contact>> onSelectionChanged;

  const MeetingStepParticipants({
    Key? key,
    required this.allContacts,
    required this.selectedContacts,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: allContacts.map((contact) {
        final isSelected = selectedContacts.contains(contact);
        return CheckboxListTile(
          value: isSelected,
          title: Text(contact.displayName),
          subtitle: Text(contact.phone ?? ''),
          onChanged: (checked) {
            final newList = List<Contact>.from(selectedContacts);
            if (checked == true) {
              if (!newList.contains(contact)) newList.add(contact);
            } else {
              newList.remove(contact);
            }
            onSelectionChanged(newList);
          },
        );
      }).toList(),
    );
  }
}
