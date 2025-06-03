import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reminder_providers.dart';
import '../../../models/reminder.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateReminderScreen extends ConsumerStatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  ConsumerState<CreateReminderScreen> createState() =>
      _CreateReminderScreenState();
}

class _CreateReminderScreenState extends ConsumerState<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;

  bool _isSaving = false;

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    setState(() => _isSaving = true);

    final reminder = Reminder(
      id: '', // Firestore will assign the ID
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      isCompleted: false,
      scheduledTime: _selectedDate!,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    try {
      await ref.read(reminderServiceProvider).addReminder(reminder);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving reminder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedDate != null
                      ? 'Scheduled: ${_selectedDate!.toLocal()}'.split(' ')[0]
                      : 'Pick a date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && mounted) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
