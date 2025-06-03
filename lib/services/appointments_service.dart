/// Appointments Service
///
/// This service handles all CRUD operations for appointments in Firestore.
/// It provides methods for creating, reading, updating, and deleting appointments.
///
/// Features:
/// - Create new appointments
/// - Read appointments (stream and single)
/// - Update existing appointments
/// - Delete appointments
/// - Real-time updates
/// - Batch operations
/// - Query filters
/// - Offline support
/// - Data validation
///
/// Dependencies:
/// - Cloud Firestore for data storage
/// - Firebase Auth for user authentication
///
/// TODO:
/// - Add batch operations for multiple appointments
/// - Add query filters (by date range, location, etc.)
/// - Add offline support
/// - Add data validation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';
import '../models/meeting_stats.dart';

abstract class AuthService {
  String? get currentUserId;
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  @override
  String? get currentUserId => _auth.currentUser?.uid;
}

/// Service class for managing appointments in Firestore
class AppointmentsService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  AppointmentsService({
    FirebaseFirestore? firestore,
    AuthService? authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService =
            authService ?? FirebaseAuthService(FirebaseAuth.instance) {
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  CollectionReference<Map<String, dynamic>> get _appointmentsCollection =>
      _firestore.collection('appointments');

  /// Validates an appointment
  ///
  /// Throws:
  /// - Exception if validation fails
  void _validateAppointment(Appointment appointment) {
    if (appointment.title.isEmpty) {
      throw Exception('Title is required');
    }
    if (appointment.datetime.isBefore(DateTime.now())) {
      throw Exception('Appointment date must be in the future');
    }
    if (appointment.participants.isEmpty) {
      throw Exception('At least one participant is required');
    }
  }

  /// Creates multiple appointments in a batch
  ///
  /// Parameters:
  /// - appointments: List of appointments to create
  ///
  /// Returns:
  /// - Future<List<String>> that completes with the created appointment IDs
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  /// - Exception if validation fails
  Future<List<String>> createAppointmentsBatch(
      List<Appointment> appointments) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Validate all appointments
    for (final appointment in appointments) {
      _validateAppointment(appointment);
    }

    final batch = _firestore.batch();
    final docRefs = appointments.map((appointment) {
      final docRef = _appointmentsCollection.doc();
      batch.set(docRef, {
        'title': appointment.title,
        'datetime': Timestamp.fromDate(appointment.datetime),
        'location': appointment.location,
        'notes': appointment.notes,
        'participants': appointment.participants,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef;
    }).toList();

    await batch.commit();
    return docRefs.map((ref) => ref.id).toList();
  }

  /// Creates a new appointment in Firestore
  ///
  /// Parameters:
  /// - appointment: The appointment to create
  ///
  /// Returns:
  /// - Future<String> that completes with the created appointment ID
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  /// - Exception if validation fails
  Future<String> createAppointment(Appointment appointment) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    _validateAppointment(appointment);

    final docRef = await _appointmentsCollection.add({
      'title': appointment.title,
      'datetime': Timestamp.fromDate(appointment.datetime),
      'location': appointment.location,
      'notes': appointment.notes,
      'participants': appointment.participants,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Updates multiple appointments in a batch
  ///
  /// Parameters:
  /// - appointments: List of appointments to update
  ///
  /// Returns:
  /// - Future<void> that completes when all appointments are updated
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  /// - Exception if validation fails
  Future<void> updateAppointmentsBatch(List<Appointment> appointments) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Validate all appointments
    for (final appointment in appointments) {
      _validateAppointment(appointment);
    }

    final batch = _firestore.batch();
    for (final appointment in appointments) {
      final docRef = _appointmentsCollection.doc(appointment.id);
      batch.update(docRef, {
        'title': appointment.title,
        'datetime': Timestamp.fromDate(appointment.datetime),
        'location': appointment.location,
        'notes': appointment.notes,
        'participants': appointment.participants,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Updates an existing appointment in Firestore
  ///
  /// Parameters:
  /// - appointment: The appointment to update
  ///
  /// Returns:
  /// - Future<void> that completes when the appointment is updated
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  /// - Exception if validation fails
  Future<void> updateAppointment(Appointment appointment) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    _validateAppointment(appointment);

    await _appointmentsCollection.doc(appointment.id).update({
      'title': appointment.title,
      'datetime': Timestamp.fromDate(appointment.datetime),
      'location': appointment.location,
      'notes': appointment.notes,
      'participants': appointment.participants,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes multiple appointments in a batch
  ///
  /// Parameters:
  /// - appointmentIds: List of appointment IDs to delete
  ///
  /// Returns:
  /// - Future<void> that completes when all appointments are deleted
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  Future<void> deleteAppointmentsBatch(List<String> appointmentIds) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final batch = _firestore.batch();
    for (final id in appointmentIds) {
      final docRef = _appointmentsCollection.doc(id);
      batch.delete(docRef);
    }

    await batch.commit();
  }

  /// Deletes an appointment from Firestore
  ///
  /// Parameters:
  /// - appointmentId: The ID of the appointment to delete
  ///
  /// Returns:
  /// - Future<void> that completes when the appointment is deleted
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  Future<void> deleteAppointment(String appointmentId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    await _appointmentsCollection.doc(appointmentId).delete();
  }

  /// Gets a stream of appointments for the current user
  ///
  /// Returns:
  /// - Stream<List<Appointment>> that emits the user's appointments
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  Stream<List<Appointment>> getAppointmentsStream() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    return _appointmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('datetime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Appointment(
          id: doc.id,
          title: data['title'] as String,
          datetime: (data['datetime'] as Timestamp).toDate(),
          location: data['location'] as String?,
          notes: data['notes'] as String?,
          participants: List<String>.from(data['participants'] as List),
          userId: data['userId'] as String,
        );
      }).toList();
    });
  }

  /// Gets a single appointment by ID
  ///
  /// Parameters:
  /// - appointmentId: The ID of the appointment to get
  ///
  /// Returns:
  /// - Future<Appointment?> that completes with the appointment, or null if not found
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  Future<Appointment?> getAppointment(String appointmentId) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final doc = await _appointmentsCollection.doc(appointmentId).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    return Appointment(
      id: doc.id,
      title: data['title'] as String,
      datetime: (data['datetime'] as Timestamp).toDate(),
      location: data['location'] as String?,
      notes: data['notes'] as String?,
      participants: List<String>.from(data['participants'] as List),
      userId: data['userId'] as String,
    );
  }

  /// Gets meeting statistics for the current user
  ///
  /// Returns:
  /// - Future<MeetingStats> that completes with the user's meeting statistics
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  Future<MeetingStats> getMeetingStats() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final snapshot = await _appointmentsCollection
        .where('userId', isEqualTo: userId)
        .where('datetime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('datetime', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final totalMeetings = snapshot.docs.length;
    final completedMeetings = snapshot.docs
        .where((doc) =>
            (doc.data()['datetime'] as Timestamp).toDate().isBefore(now))
        .length;
    final upcomingMeetings = totalMeetings - completedMeetings;

    final stats = MeetingStats(
      totalMeetings: totalMeetings,
      totalClients: totalMeetings,
      activeClients: completedMeetings,
      newClients: upcomingMeetings,
      recurringClients: 0,
      weeklyMeetings: 0,
      monthlyMeetings: 0,
      topClientMeetings: 0,
    );

    return stats;
  }
}
