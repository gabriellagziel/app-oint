import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'meeting_draft.freezed.dart';
part 'meeting_draft.g.dart';

/// Represents a draft state of a meeting being created
@freezed
class MeetingDraft with _$MeetingDraft {
  const factory MeetingDraft({
    required String uuid,
    required DateTime datetime,
    required String meetingType,
    required String location,
    required String notes,
  }) = _MeetingDraft;

  const MeetingDraft._(); // Added private constructor for custom getters

  factory MeetingDraft.fromJson(Map<String, dynamic> json) =>
      _$MeetingDraftFromJson(json);
}

/// Extension methods for MeetingDraft
extension MeetingDraftX on MeetingDraft {
  /// Creates a copy of the draft with updated fields
  MeetingDraft copyWith({
    String? uuid,
    DateTime? datetime,
    String? meetingType,
    String? location,
    String? notes,
  }) {
    return MeetingDraft(
      uuid: uuid ?? this.uuid,
      datetime: datetime ?? this.datetime,
      meetingType: meetingType ?? this.meetingType,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  /// Validates if all required fields are filled
  bool get isValid {
    return datetime.isAfter(DateTime.now()) &&
        meetingType.isNotEmpty &&
        location.isNotEmpty &&
        notes.isNotEmpty;
  }

  /// Validates the title field
  String? validateTitle() {
    if (uuid.isEmpty) {
      return 'Please enter a meeting UUID';
    }
    return null;
  }

  /// Validates the datetime field
  String? validateDateTime() {
    if (datetime.isBefore(DateTime.now())) {
      return 'Meeting time must be in the future';
    }
    return null;
  }

  /// Validates the meeting type field
  String? validateMeetingType() {
    if (meetingType.isEmpty) {
      return 'Please select a meeting type';
    }
    return null;
  }

  /// Validates the location field
  String? validateLocation() {
    if (location.isNotEmpty && location.length > 200) {
      return 'Location must be less than 200 characters';
    }
    return null;
  }

  /// Validates the notes field
  String? validateNotes() {
    if (notes.isNotEmpty && notes.length > 1000) {
      return 'Notes must be less than 1000 characters';
    }
    return null;
  }

  /// Validates the current step
  String? validateCurrentStep() {
    switch (datetime.difference(DateTime.now()).inHours ~/ 24) {
      case 0:
        return validateTitle();
      case 1:
        return validateDateTime();
      case 2:
        return validateMeetingType();
      case 3:
        return validateLocation();
      case 4:
        return validateNotes();
      default:
        return null;
    }
  }
}

class MeetingDraftError implements Exception {
  final String message;
  MeetingDraftError(this.message);

  @override
  String toString() => message;
}
