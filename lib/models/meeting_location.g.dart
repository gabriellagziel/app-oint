// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingLocationImpl _$$MeetingLocationImplFromJson(
        Map<String, dynamic> json) =>
    _$MeetingLocationImpl(
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLink: json['zoomLink'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$$MeetingLocationImplToJson(
        _$MeetingLocationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'zoomLink': instance.zoomLink,
      'phoneNumber': instance.phoneNumber,
    };
