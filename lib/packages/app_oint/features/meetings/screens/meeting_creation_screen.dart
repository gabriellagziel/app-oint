import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/meeting.dart';
import '../services/meeting_service.dart';

class MeetingCreationScreen extends StatefulWidget {
  const MeetingCreationScreen({super.key});

  @override
  State<MeetingCreationScreen> createState() => _MeetingCreationScreenState();
}

class _MeetingCreationScreenState extends State<MeetingCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  DateTime? _startsAt;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    if (!mounted) return;
    setState(() {
      _startsAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startsAt == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pick a date/time')));
      return;
    }
    final meeting = Meeting(title: _titleCtl.text.trim(), startsAt: _startsAt!);
    await MeetingService.instance.create(meeting);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _startsAt == null
        ? 'Choose date & time'
        : DateFormat.yMMMEd().add_jm().format(_startsAt!);

    return Scaffold(
      appBar: AppBar(title: const Text('New meeting')),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(dateLabel),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDateTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
