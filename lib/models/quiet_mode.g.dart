// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiet_mode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuietModeImpl _$$QuietModeImplFromJson(Map<String, dynamic> json) =>
    _$QuietModeImpl(
      enabled: json['enabled'] as bool,
      quietUntil: DateTime.parse(json['quietUntil'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$$QuietModeImplToJson(_$QuietModeImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'quietUntil': instance.quietUntil.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
    };
