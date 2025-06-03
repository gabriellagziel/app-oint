/// Enum representing different types of meetings
enum MeetingType {
  /// Physical meeting at a location
  inPerson,

  /// Video call meeting (Zoom, etc.)
  videoCall,

  /// Phone call meeting
  phoneCall,

  /// Hybrid meeting (combination of in-person and video call)
  hybrid,
}

extension MeetingTypeExtension on MeetingType {
  String get displayName {
    switch (this) {
      case MeetingType.inPerson:
        return 'In-Person';
      case MeetingType.videoCall:
        return 'Video Call';
      case MeetingType.phoneCall:
        return 'Phone Call';
      case MeetingType.hybrid:
        return 'Hybrid';
    }
  }
}
