// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingDraftImpl _$$MeetingDraftImplFromJson(Map<String, dynamic> json) =>
    _$MeetingDraftImpl(
      uuid: json['uuid'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      meetingType: json['meetingType'] as String,
      location: json['location'] as String,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$$MeetingDraftImplToJson(_$MeetingDraftImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'datetime': instance.datetime.toIso8601String(),
      'meetingType': instance.meetingType,
      'location': instance.location,
      'notes': instance.notes,
    };
