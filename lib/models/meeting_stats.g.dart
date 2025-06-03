// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingStatsImpl _$$MeetingStatsImplFromJson(Map<String, dynamic> json) =>
    _$MeetingStatsImpl(
      totalMeetings: (json['totalMeetings'] as num).toInt(),
      totalClients: (json['totalClients'] as num).toInt(),
      activeClients: (json['activeClients'] as num).toInt(),
      newClients: (json['newClients'] as num).toInt(),
      recurringClients: (json['recurringClients'] as num).toInt(),
      weeklyMeetings: (json['weeklyMeetings'] as num).toInt(),
      monthlyMeetings: (json['monthlyMeetings'] as num).toInt(),
      topClientMeetings: (json['topClientMeetings'] as num).toInt(),
      topClientName: json['topClientName'] as String?,
    );

Map<String, dynamic> _$$MeetingStatsImplToJson(_$MeetingStatsImpl instance) =>
    <String, dynamic>{
      'totalMeetings': instance.totalMeetings,
      'totalClients': instance.totalClients,
      'activeClients': instance.activeClients,
      'newClients': instance.newClients,
      'recurringClients': instance.recurringClients,
      'weeklyMeetings': instance.weeklyMeetings,
      'monthlyMeetings': instance.monthlyMeetings,
      'topClientMeetings': instance.topClientMeetings,
      'topClientName': instance.topClientName,
    };
