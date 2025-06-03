import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting_location.freezed.dart';
part 'meeting_location.g.dart';

@freezed
class MeetingLocation with _$MeetingLocation {
  const factory MeetingLocation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? zoomLink,
    String? phoneNumber,
  }) = _MeetingLocation;

  factory MeetingLocation.fromJson(Map<String, dynamic> json) =>
      _$MeetingLocationFromJson(json);
}
