import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_model.freezed.dart';
part 'test_model.g.dart';

@freezed
class TestModel with _$TestModel {
  const factory TestModel({
    required String id,
    required String name,
  }) = _TestModel;

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);
}
