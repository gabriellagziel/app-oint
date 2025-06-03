import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting_stats.freezed.dart';
part 'meeting_stats.g.dart';

@freezed
class MeetingStats with _$MeetingStats {
  const factory MeetingStats({
    required int totalMeetings,
    required int totalClients,
    required int activeClients,
    required int newClients,
    required int recurringClients,
    required int weeklyMeetings,
    required int monthlyMeetings,
    required int topClientMeetings,
    String? topClientName,
  }) = _MeetingStats;

  factory MeetingStats.fromJson(Map<String, dynamic> json) =>
      _$MeetingStatsFromJson(json);
}
