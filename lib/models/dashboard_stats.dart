import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    required int totalMeetingsLastMonth,
    required int newClients,
    required int returningClients,
    required int inactiveClients,
    required List<WeeklyMeetingData> weeklyMeetings,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}

@freezed
class WeeklyMeetingData with _$WeeklyMeetingData {
  const factory WeeklyMeetingData({
    required DateTime weekStart,
    required int meetingCount,
  }) = _WeeklyMeetingData;

  factory WeeklyMeetingData.fromJson(Map<String, dynamic> json) =>
      _$WeeklyMeetingDataFromJson(json);
}
