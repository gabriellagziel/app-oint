/// Personal Dashboard Screen
///
/// This screen serves as the main interface for users after logging in.
/// It displays the user's profile information and a list of their appointments.
///
/// Features:
/// - User profile display (name, email, photo)
/// - Appointment list with filtering (All/Today/Week)
/// - Add/Edit/Delete appointments
/// - External calendar integration
/// - Responsive design (mobile/desktop)
///
/// Dependencies:
/// - Firebase Auth for user data
/// - Cloud Firestore for appointments
/// - Riverpod for state management
/// - URL Launcher for calendar integration
///
/// TODO:
/// - Implement full Google/Apple Calendar API integration
/// - Add Facebook/Apple authentication
/// - Add profile and settings screens

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/google_sign_in_service.dart';
import '../providers/appointments_service_provider.dart';
import '../models/appointment.dart';
import 'appointment_edit_screen.dart';

/// Provider for appointments stream
/// Returns a real-time stream of appointments for the current user
final appointmentsStreamProvider = StreamProvider<List<Appointment>>((ref) {
  final service = ref.watch(appointmentsServiceProvider);
  return service.getAppointmentsStream();
});

/// Provider for appointment filter
/// Controls the current filter state (All/Today/Week)
final appointmentFilterProvider = StateProvider<AppointmentFilter>((ref) {
  return AppointmentFilter.all;
});

/// Enum for appointment filtering options
enum AppointmentFilter {
  /// Show all appointments
  all,

  /// Show only today's appointments
  today,

  /// Show appointments for the current week
  week,
}

/// Main dashboard screen that displays user profile and appointments
class PersonalDashboardScreen extends ConsumerWidget {
  const PersonalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final appointmentsAsync = ref.watch(appointmentsStreamProvider);
    final filter = ref.watch(appointmentFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('APP-OINT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => GoogleSignInService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: isSmallScreen ? _buildDrawer(context) : null,
      body: Row(
        children: [
          if (!isSmallScreen) _buildDrawer(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(user),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Appointments',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          SegmentedButton<AppointmentFilter>(
                            segments: const [
                              ButtonSegment(
                                value: AppointmentFilter.all,
                                label: Text('All'),
                                icon: Icon(Icons.calendar_month),
                              ),
                              ButtonSegment(
                                value: AppointmentFilter.today,
                                label: Text('Today'),
                                icon: Icon(Icons.today),
                              ),
                              ButtonSegment(
                                value: AppointmentFilter.week,
                                label: Text('Week'),
                                icon: Icon(Icons.view_week),
                              ),
                            ],
                            selected: {filter},
                            onSelectionChanged:
                                (Set<AppointmentFilter> selected) {
                              ref
                                  .read(appointmentFilterProvider.notifier)
                                  .state = selected.first;
                            },
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            onPressed: () => _openAppointmentEdit(context),
                            icon: const Icon(Icons.add),
                            label: const Text('New Appointment'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: appointmentsAsync.when(
                      data: (appointments) {
                        final filteredAppointments =
                            _filterAppointments(appointments, filter);
                        return filteredAppointments.isEmpty
                            ? const Center(
                                child: Text(
                                  'No appointments found',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredAppointments.length,
                                itemBuilder: (context, index) {
                                  final appointment =
                                      filteredAppointments[index];
                                  return _buildAppointmentCard(
                                    context,
                                    appointment,
                                  );
                                },
                              );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Filters appointments based on the selected filter
  List<Appointment> _filterAppointments(
      List<Appointment> appointments, AppointmentFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    switch (filter) {
      case AppointmentFilter.today:
        return appointments.where((a) {
          final appointmentDate =
              DateTime(a.datetime.year, a.datetime.month, a.datetime.day);
          return appointmentDate == today;
        }).toList();
      case AppointmentFilter.week:
        return appointments.where((a) {
          final appointmentDate =
              DateTime(a.datetime.year, a.datetime.month, a.datetime.day);
          return appointmentDate
                  .isAfter(today.subtract(const Duration(days: 1))) &&
              appointmentDate.isBefore(weekEnd);
        }).toList();
      case AppointmentFilter.all:
        return appointments;
    }
  }

  /// Builds the user info card with profile picture and details
  Widget _buildUserInfo(User? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an appointment card with details and actions
  Widget _buildAppointmentCard(
    BuildContext context,
    Appointment appointment,
  ) {
    final isToday = _isToday(appointment.datetime);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(appointment.datetime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isToday ? Colors.deepPurple.withAlpha(26) : null,
      child: ListTile(
        title: Text(
          appointment.title,
          style: TextStyle(
            fontWeight: isToday ? FontWeight.bold : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
            if (appointment.location != null &&
                appointment.location!.isNotEmpty)
              Text('Location: ${appointment.location}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _addToExternalCalendar(appointment),
              tooltip: 'Add to external calendar',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openAppointmentEdit(
                context,
                appointment: appointment,
              ),
              tooltip: 'Edit appointment',
            ),
          ],
        ),
      ),
    );
  }

  /// Checks if a given date is today
  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Adds an appointment to the external calendar
  /// Currently opens Google Calendar with basic details
  /// TODO: Implement full Google/Apple Calendar API integration
  Future<void> _addToExternalCalendar(Appointment appointment) async {
    final dateFormat = DateFormat('yyyyMMdd\'T\'HHmmss');
    final startTime = dateFormat.format(appointment.datetime);
    final endTime = dateFormat.format(
      appointment.datetime.add(const Duration(hours: 1)),
    );

    final url = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(appointment.title)}'
      '&dates=$startTime/$endTime'
      '&details=${Uri.encodeComponent(appointment.notes ?? '')}'
      '&location=${Uri.encodeComponent(appointment.location ?? '')}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // TODO: Show error dialog
    }
  }

  /// Builds the navigation drawer with app menu
  Widget _buildDrawer(BuildContext context) {
    return NavigationDrawer(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                'APP-OINT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () {
            // TODO: Navigate to profile
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            // TODO: Navigate to settings
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            GoogleSignInService.signOut();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  /// Opens the appointment edit screen
  void _openAppointmentEdit(
    BuildContext context, {
    Appointment? appointment,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentEditScreen(
          appointment: appointment,
        ),
      ),
    );
  }
}
