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
            authService ?? FirebaseAuthService(FirebaseAuth.instance);

  CollectionReference<Map<String, dynamic>> get _appointmentsCollection =>
      _firestore.collection('appointments');

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
  /// - Exception if required fields are missing
  Future<String> createAppointment(Appointment appointment) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Validate required fields
    if (appointment.title.isEmpty) {
      throw Exception('Title is required');
    }
    if (appointment.datetime.isBefore(DateTime.now())) {
      throw Exception('Appointment date must be in the future');
    }

    // Create the appointment document
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
  Future<void> updateAppointment(Appointment appointment) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    await _appointmentsCollection.doc(appointment.id).update({
      'title': appointment.title,
      'datetime': Timestamp.fromDate(appointment.datetime),
      'location': appointment.location,
      'notes': appointment.notes,
      'participants': appointment.participants,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes an appointment from Firestore
  ///
  /// Parameters:
  /// - id: The ID of the appointment to delete
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
  /// - Stream<List<Appointment>> that emits the list of appointments
  ///   whenever it changes in Firestore
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  Stream<List<Appointment>> getAppointmentsStream() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _appointmentsCollection
        .where('userId', isEqualTo: userId)
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
          participants: List<String>.from(data['participants'] ?? []),
          userId: data['userId'] as String,
        );
      }).toList();
    });
  }

  /// Gets a single appointment by ID
  ///
  /// Parameters:
  /// - id: The ID of the appointment to get
  ///
  /// Returns:
  /// - Future<Appointment?> that completes with the appointment if found,
  ///   or null if not found
  ///
  /// Throws:
  /// - Exception if the user is not logged in
  Future<Appointment?> getAppointment(String id) async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final doc = await _appointmentsCollection.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return Appointment(
      id: doc.id,
      title: data['title'] as String,
      datetime: (data['datetime'] as Timestamp).toDate(),
      location: data['location'] as String?,
      notes: data['notes'] as String?,
      participants: List<String>.from(data['participants'] ?? []),
      userId: data['userId'] as String,
    );
  }
}
