import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

class Meeting {
  final String id;
  final String title;
  final DateTime startsAt;
  final String? description;
  final String creatorId;

  Meeting({
    required this.id,
    required this.title,
    required this.startsAt,
    this.description,
    required this.creatorId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startsAt': startsAt.toIso8601String(),
    'description': description,
    'creatorId': creatorId,
  };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json['id'] as String,
    title: json['title'] as String,
    startsAt: DateTime.parse(json['startsAt'] as String),
    description: json['description'] as String?,
    creatorId: json['creatorId'] as String,
  );
}

DateTime _dateFromJson(Timestamp timestamp) => timestamp.toDate();
Timestamp _dateToJson(DateTime date) => Timestamp.fromDate(date);
Duration _durationFromJson(int minutes) => Duration(minutes: minutes);
int _durationToJson(Duration duration) => duration.inMinutes;
