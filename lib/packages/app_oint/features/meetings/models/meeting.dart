import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

@freezed
class Meeting with _$Meeting {
  const factory Meeting({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'new', fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime date,
    @JsonKey(name: 'new', fromJson: _durationFromJson, toJson: _durationToJson)
    required Duration duration,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);
}

DateTime _dateFromJson(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateToJson(DateTime date) => Timestamp.fromDate(date);
Duration _durationFromJson(int minutes) => Duration(minutes: minutes);
int _durationToJson(Duration duration) => duration.inMinutes;
