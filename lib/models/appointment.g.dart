// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentImpl _$$AppointmentImplFromJson(Map<String, dynamic> json) =>
    _$AppointmentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$AppointmentImplToJson(_$AppointmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'datetime': instance.datetime.toIso8601String(),
      'location': instance.location,
      'notes': instance.notes,
      'participants': instance.participants,
      'userId': instance.userId,
    };
