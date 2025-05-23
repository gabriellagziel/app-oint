import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_simple.freezed.dart';
part 'test_simple.g.dart';

@freezed
class TestSimple with _$TestSimple {
  const factory TestSimple({
    required String id,
  }) = _TestSimple;

  factory TestSimple.fromJson(Map<String, dynamic> json) =>
      _$TestSimpleFromJson(json);
}
