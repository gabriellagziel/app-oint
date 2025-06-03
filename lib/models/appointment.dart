/// Appointment Model
///
/// This class represents an appointment in the application.
/// It includes all necessary fields for storing appointment data
/// and methods for converting to/from Firestore documents.
///
/// Fields:
/// - id: Unique identifier for the appointment
/// - title: Title/name of the appointment
/// - datetime: Date and time of the appointment
/// - location: Location of the appointment
/// - notes: Optional notes about the appointment
/// - userId: ID of the user who owns the appointment
/// - participants: List of participant IDs
///
/// Dependencies:
/// - Cloud Firestore for data storage
///
/// TODO:
/// - Add validation for fields
/// - Add support for recurring appointments
/// - Add support for reminders
/// - Add support for attendees

import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

/// Model class for appointments
@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String title,
    required DateTime datetime,
    String? location,
    String? notes,
    @Default([]) List<String> participants,
    required String userId,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
}
