/// Appointment Edit Screen
///
/// This screen handles both creation and editing of appointments.
/// It provides a form for entering appointment details with validation.
///
/// Features:
/// - Create new appointments
/// - Edit existing appointments
/// - Delete appointments
/// - Form validation
/// - Loading states
/// - Error handling
///
/// Dependencies:
/// - Cloud Firestore for appointments
/// - Riverpod for state management
///
/// TODO:
/// - Add location picker/map integration
/// - Add recurring appointment options
/// - Add reminder settings
/// - Handle null appointment gracefully in form initialization

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../providers/appointments_service_provider.dart';

/// Provider for appointment form state
/// Manages the form data and validation state
final appointmentFormProvider =
    StateNotifierProvider<AppointmentFormNotifier, AppointmentFormState>((ref) {
  return AppointmentFormNotifier();
});

/// State class for appointment form
class AppointmentFormState {
  final String title;
  final DateTime datetime;
  final String location;
  final String? notes;
  final bool isLoading;
  final String? error;

  AppointmentFormState({
    this.title = '',
    DateTime? datetime,
    this.location = '',
    this.notes,
    this.isLoading = false,
    this.error,
  }) : datetime = datetime ?? DateTime.now();

  AppointmentFormState copyWith({
    String? title,
    DateTime? datetime,
    String? location,
    String? notes,
    bool? isLoading,
    String? error,
  }) {
    return AppointmentFormState(
      title: title ?? this.title,
      datetime: datetime ?? this.datetime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for appointment form state
class AppointmentFormNotifier extends StateNotifier<AppointmentFormState> {
  AppointmentFormNotifier() : super(AppointmentFormState());

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDatetime(DateTime datetime) {
    state = state.copyWith(datetime: datetime);
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = AppointmentFormState();
  }
}

/// Screen for creating and editing appointments
class AppointmentEditScreen extends ConsumerStatefulWidget {
  final Appointment? appointment;

  const AppointmentEditScreen({
    super.key,
    this.appointment,
  });

  @override
  ConsumerState<AppointmentEditScreen> createState() =>
      _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends ConsumerState<AppointmentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.appointment?.title ?? '';
    _locationController.text = widget.appointment?.location ?? '';
    _notesController.text = widget.appointment?.notes ?? '';
    _selectedDateTime = widget.appointment?.datetime ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment == null
            ? 'New Appointment'
            : 'Edit Appointment'),
        actions: [
          if (widget.appointment != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteAppointment,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
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
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date & Time'),
                    subtitle: Text(
                      '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')} '
                      '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    // ignore: use_build_context_synchronously
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date == null) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                      );
                      if (time == null) return;

                      if (!mounted) return;
                      final newDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      // ignore: use_build_context_synchronously
                      // ignore: use_build_context_synchronously
                      setState(() {
                        _selectedDateTime = newDateTime;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveAppointment,
                    child: Text(widget.appointment == null ? 'Create' : 'Save'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appointmentsService = ref.read(appointmentsServiceProvider);
      final appointment = Appointment(
        id: widget.appointment?.id ?? '',
        title: _titleController.text,
        datetime: _selectedDateTime,
        location: _locationController.text,
        notes: _notesController.text,
        participants: widget.appointment?.participants ?? [],
        userId: widget.appointment?.userId ?? '',
      );

      if (widget.appointment == null) {
        await appointmentsService.createAppointment(appointment);
      } else {
        await appointmentsService.updateAppointment(appointment);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAppointment() async {
    if (widget.appointment == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content:
            const Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final appointmentsService = ref.read(appointmentsServiceProvider);
      await appointmentsService.deleteAppointment(widget.appointment!.id);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
