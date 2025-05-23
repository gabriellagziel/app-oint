import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_freezed.freezed.dart';
part 'test_freezed.g.dart';

@freezed
class TestFreezed with _$TestFreezed {
  const factory TestFreezed({
    required String id,
    required String name,
  }) = _TestFreezed;

  factory TestFreezed.fromJson(Map<String, dynamic> json) =>
      _$TestFreezedFromJson(json);
}
