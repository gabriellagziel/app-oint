import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'new', fromJson: _dateFromJson, toJson: _dateToJson)
    required DateTime dueDate,
    @Default(false) bool isCompleted,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

DateTime _dateFromJson(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateToJson(DateTime date) => Timestamp.fromDate(date);
