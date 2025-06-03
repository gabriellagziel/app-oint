// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientImpl _$$ClientImplFromJson(Map<String, dynamic> json) => _$ClientImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      meetingCount: (json['meetingCount'] as num).toInt(),
      lastMeetingDate: DateTime.parse(json['lastMeetingDate'] as String),
      status: $enumDecode(_$ClientStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$ClientImplToJson(_$ClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'meetingCount': instance.meetingCount,
      'lastMeetingDate': instance.lastMeetingDate.toIso8601String(),
      'status': _$ClientStatusEnumMap[instance.status]!,
    };

const _$ClientStatusEnumMap = {
  ClientStatus.active: 'active',
  ClientStatus.inactive: 'inactive',
  ClientStatus.new_: 'new',
};
