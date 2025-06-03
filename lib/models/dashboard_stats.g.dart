// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      totalMeetingsLastMonth: (json['totalMeetingsLastMonth'] as num).toInt(),
      newClients: (json['newClients'] as num).toInt(),
      returningClients: (json['returningClients'] as num).toInt(),
      inactiveClients: (json['inactiveClients'] as num).toInt(),
      weeklyMeetings: (json['weeklyMeetings'] as List<dynamic>)
          .map((e) => WeeklyMeetingData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
        _$DashboardStatsImpl instance) =>
    <String, dynamic>{
      'totalMeetingsLastMonth': instance.totalMeetingsLastMonth,
      'newClients': instance.newClients,
      'returningClients': instance.returningClients,
      'inactiveClients': instance.inactiveClients,
      'weeklyMeetings': instance.weeklyMeetings,
    };

_$WeeklyMeetingDataImpl _$$WeeklyMeetingDataImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyMeetingDataImpl(
      weekStart: DateTime.parse(json['weekStart'] as String),
      meetingCount: (json['meetingCount'] as num).toInt(),
    );

Map<String, dynamic> _$$WeeklyMeetingDataImplToJson(
        _$WeeklyMeetingDataImpl instance) =>
    <String, dynamic>{
      'weekStart': instance.weekStart.toIso8601String(),
      'meetingCount': instance.meetingCount,
    };
