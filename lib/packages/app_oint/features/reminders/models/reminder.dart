import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'new', fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime dueDate,
    @JsonKey(name: 'new', fromJson: _durationFromJson, toJson: _durationToJson)
    Duration? duration,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}

DateTime _dateFromJson(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateToJson(DateTime date) => Timestamp.fromDate(date);
Duration? _durationFromJson(int? minutes) =>
    minutes != null ? Duration(minutes: minutes) : null;
int? _durationToJson(Duration? duration) => duration?.inMinutes;
