import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart'; // Required for Freezed + Diagnostics

part 'meeting_draft.freezed.dart';
part 'meeting_draft.g.dart';

/// Represents a draft state of a meeting being created
@freezed
class MeetingDraft with _$MeetingDraft {
  const factory MeetingDraft({
    @Default('') String title,
    @Default('') String location,
    DateTime? datetime,
    @Default([]) List<String> participants,
    @Default('') String meetingType,
    @Default('') String notes,
    @Default('') String imageUrl,
    @Default(0) int currentStep,
    @Default(false) bool isComplete,
  }) = _MeetingDraft;

  const MeetingDraft._(); // Added private constructor for custom getters

  factory MeetingDraft.fromJson(Map<String, dynamic> json) =>
      _$MeetingDraftFromJson(json);
}

/// Extension methods for MeetingDraft
extension MeetingDraftX on MeetingDraft {
  /// Creates a copy of the draft with updated fields
  MeetingDraft copyWith({
    String? title,
    String? location,
    DateTime? datetime,
    List<String>? participants,
    String? meetingType,
    String? notes,
    String? imageUrl,
    int? currentStep,
    bool? isComplete,
  }) {
    return MeetingDraft(
      title: title ?? this.title,
      location: location ?? this.location,
      datetime: datetime ?? this.datetime,
      participants: participants ?? this.participants,
      meetingType: meetingType ?? this.meetingType,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Validates if all required fields are filled
  bool get isValid {
    return title.isNotEmpty &&
        datetime != null &&
        participants.isNotEmpty &&
        meetingType.isNotEmpty;
  }

  /// Returns the next step number
  int get nextStep => currentStep + 1;

  /// Returns the previous step number
  int get previousStep => currentStep - 1;

  /// Checks if there is a next step available
  bool get hasNextStep => currentStep < 5; // Assuming 6 steps total (0-5)

  /// Checks if there is a previous step available
  bool get hasPreviousStep => currentStep > 0;

  /// Validates the title field
  String? validateTitle() {
    if (title.isEmpty) {
      return 'Please enter a meeting title';
    }
    if (title.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  /// Validates the datetime field
  String? validateDateTime() {
    if (datetime == null) {
      return 'Please select a date and time';
    }
    if (datetime!.isBefore(DateTime.now())) {
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

  /// Validates the participants field
  String? validateParticipants() {
    if (participants.isEmpty) {
      return 'Please add at least one participant';
    }
    if (participants.length > 50) {
      return 'Maximum 50 participants allowed';
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
    switch (currentStep) {
      case 0:
        return validateTitle();
      case 1:
      case 2:
        return validateDateTime();
      case 3:
        return validateMeetingType();
      case 4:
        return validateParticipants();
      case 5:
        return validateLocation();
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
