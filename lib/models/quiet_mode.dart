import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiet_mode.freezed.dart';
part 'quiet_mode.g.dart';

@freezed
class QuietMode with _$QuietMode {
  const factory QuietMode({
    required bool enabled,
    required DateTime quietUntil,
    required Duration duration,
  }) = _QuietMode;

  factory QuietMode.disabled() => QuietMode(
        enabled: false,
        quietUntil: DateTime.now(),
        duration: const Duration(minutes: 30),
      );

  factory QuietMode.fromJson(Map<String, dynamic> json) =>
      _$QuietModeFromJson(json);
}
