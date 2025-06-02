// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingDraftImpl _$$MeetingDraftImplFromJson(Map<String, dynamic> json) =>
    _$MeetingDraftImpl(
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      datetime: json['datetime'] == null
          ? null
          : DateTime.parse(json['datetime'] as String),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      meetingType: json['meetingType'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
    );

Map<String, dynamic> _$$MeetingDraftImplToJson(_$MeetingDraftImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'location': instance.location,
      'datetime': instance.datetime?.toIso8601String(),
      'participants': instance.participants,
      'meetingType': instance.meetingType,
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'currentStep': instance.currentStep,
      'isComplete': instance.isComplete,
    };
