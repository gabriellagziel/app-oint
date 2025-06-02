import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../providers/meeting_creation_provider.dart';
import '../providers/contact_picker_service_provider.dart';
import '../utils/localizations_helper.dart';

/// Widget for managing meeting participants
class MeetingStepParticipants extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const MeetingStepParticipants({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<MeetingStepParticipants> createState() =>
      _MeetingStepParticipantsState();
}

class _MeetingStepParticipantsState
    extends ConsumerState<MeetingStepParticipants> {
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoadingContacts = true);
    try {
      final contactPickerService = ref.read(contactPickerServiceProvider);
      _contacts = await contactPickerService.getContacts();
    } finally {
      setState(() => _isLoadingContacts = false);
    }
  }

  Future<void> _pickContact() async {
    try {
      final contactPickerService = ref.read(contactPickerServiceProvider);
      final contact = await contactPickerService.pickContact();
      if (contact != null && mounted) {
        ref
            .read(meetingCreationProvider.notifier)
            .addParticipant(contact.displayName);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitParticipants() {
    final draft = ref.read(meetingCreationProvider);
    if (draft.participants.isNotEmpty) {
      widget.onComplete();
    }
  }

  List<Contact> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts
        .where((contact) => contact.displayName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(meetingCreationProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocalizationsHelper.getString(
                  context, 'meeting_participants_step'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: LocalizationsHelper.getString(
                    context, 'meeting_participants_search'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Selected participants
            if (draft.participants.isNotEmpty) ...[
              Text(
                LocalizationsHelper.getString(
                    context, 'meeting_participants_selected'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: draft.participants.map((participant) {
                  return Chip(
                    label: Text(participant),
                    onDeleted: () {
                      ref
                          .read(meetingCreationProvider.notifier)
                          .removeParticipant(participant);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            // Contact list
            if (_isLoadingContacts)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    final isSelected =
                        draft.participants.contains(contact.displayName);
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(contact.displayName[0]),
                      ),
                      title: Text(contact.displayName),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected ? Icons.remove_circle : Icons.add_circle,
                          color: isSelected ? Colors.red : Colors.green,
                        ),
                        onPressed: () {
                          if (isSelected) {
                            ref
                                .read(meetingCreationProvider.notifier)
                                .removeParticipant(contact.displayName);
                          } else {
                            ref
                                .read(meetingCreationProvider.notifier)
                                .addParticipant(contact.displayName);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickContact,
                    icon: const Icon(Icons.person_add),
                    label: Text(LocalizationsHelper.getString(
                        context, 'meeting_participants_pick')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: draft.participants.isNotEmpty
                        ? _submitParticipants
                        : null,
                    child: Text(LocalizationsHelper.getString(
                        context, 'meeting_participants_continue')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
