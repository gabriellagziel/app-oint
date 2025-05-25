import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_oint/services/invite_service.dart';
import 'package:app_oint/services/paywall_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NewMeetingScreen extends StatefulWidget {
  const NewMeetingScreen({super.key});

  @override
  State<NewMeetingScreen> createState() => _NewMeetingScreenState();
}

class _NewMeetingScreenState extends State<NewMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<String> _selectedContacts = [];
  final InviteService _inviteService = InviteService();
  bool _isCreating = false;
  Map<String, String> _inviteStatuses = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }
    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final meetingDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Create meeting in Firestore
      final meetingRef = await FirebaseFirestore.instance.collection('meetings').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dateTime': meetingDateTime.toIso8601String(),
        'organizerId': FirebaseAuth.instance.currentUser!.uid,
        'participants': _selectedContacts,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send invites and track status
      for (final phone in _selectedContacts) {
        try {
          await _inviteService.sendInvites(
            meetingId: meetingRef.id,
            inviteePhones: [phone],
            context: context,
          );
          setState(() => _inviteStatuses[phone] = 'sent');
        } catch (e) {
          setState(() => _inviteStatuses[phone] = 'failed');
          print('Failed to send invite to $phone: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting created and invites sent!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating meeting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Widget _buildInviteStatusChip(String phone, String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'sent':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Sent';
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        label = 'Failed';
        break;
      case 'external':
        color = Colors.orange;
        icon = Icons.link;
        label = 'External';
        break;
      default:
        color = Colors.grey;
        icon = Icons.pending;
        label = 'Pending';
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Meeting'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_selectedDate == null
                  ? 'Select Date'
                  : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            ListTile(
              title: Text(_selectedTime == null
                  ? 'Select Time'
                  : 'Time: ${_selectedTime!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_selectedContacts.isNotEmpty) ...[
              const Text('Selected Contacts:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _selectedContacts.map((phone) {
                  final status = _inviteStatuses[phone] ?? 'pending';
                  return _buildInviteStatusChip(phone, status);
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () async {
                final paywall = PaywallService();
                final allowed = await paywall.canCreateMoreMeetings();
                if (!allowed) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Upgrade Required'),
                      content: const Text('You've used all 5 free meetings. Upgrade to unlimited access.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => launchUrl(
                            Uri.parse('https://buy.stripe.com/link-to-checkout'),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: const Text('Upgrade (€3.99/month)'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // Proceed with creating the meeting
                await _createMeeting();
              },
              child: _isCreating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Creating Meeting...'),
                      ],
                    )
                  : const Text('Create Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}
