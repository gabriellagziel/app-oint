// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiet_mode.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QuietMode _$QuietModeFromJson(Map<String, dynamic> json) {
  return _QuietMode.fromJson(json);
}

/// @nodoc
mixin _$QuietMode {
  bool get enabled => throw _privateConstructorUsedError;
  DateTime get quietUntil => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  /// Serializes this QuietMode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuietMode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuietModeCopyWith<QuietMode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuietModeCopyWith<$Res> {
  factory $QuietModeCopyWith(QuietMode value, $Res Function(QuietMode) then) =
      _$QuietModeCopyWithImpl<$Res, QuietMode>;
  @useResult
  $Res call({bool enabled, DateTime quietUntil, Duration duration});
}

/// @nodoc
class _$QuietModeCopyWithImpl<$Res, $Val extends QuietMode>
    implements $QuietModeCopyWith<$Res> {
  _$QuietModeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuietMode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? quietUntil = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      quietUntil: null == quietUntil
          ? _value.quietUntil
          : quietUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuietModeImplCopyWith<$Res>
    implements $QuietModeCopyWith<$Res> {
  factory _$$QuietModeImplCopyWith(
          _$QuietModeImpl value, $Res Function(_$QuietModeImpl) then) =
      __$$QuietModeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enabled, DateTime quietUntil, Duration duration});
}

/// @nodoc
class __$$QuietModeImplCopyWithImpl<$Res>
    extends _$QuietModeCopyWithImpl<$Res, _$QuietModeImpl>
    implements _$$QuietModeImplCopyWith<$Res> {
  __$$QuietModeImplCopyWithImpl(
      _$QuietModeImpl _value, $Res Function(_$QuietModeImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuietMode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? quietUntil = null,
    Object? duration = null,
  }) {
    return _then(_$QuietModeImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      quietUntil: null == quietUntil
          ? _value.quietUntil
          : quietUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuietModeImpl implements _QuietMode {
  const _$QuietModeImpl(
      {required this.enabled,
      required this.quietUntil,
      required this.duration});

  factory _$QuietModeImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuietModeImplFromJson(json);

  @override
  final bool enabled;
  @override
  final DateTime quietUntil;
  @override
  final Duration duration;

  @override
  String toString() {
    return 'QuietMode(enabled: $enabled, quietUntil: $quietUntil, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuietModeImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.quietUntil, quietUntil) ||
                other.quietUntil == quietUntil) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, enabled, quietUntil, duration);

  /// Create a copy of QuietMode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuietModeImplCopyWith<_$QuietModeImpl> get copyWith =>
      __$$QuietModeImplCopyWithImpl<_$QuietModeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuietModeImplToJson(
      this,
    );
  }
}

abstract class _QuietMode implements QuietMode {
  const factory _QuietMode(
      {required final bool enabled,
      required final DateTime quietUntil,
      required final Duration duration}) = _$QuietModeImpl;

  factory _QuietMode.fromJson(Map<String, dynamic> json) =
      _$QuietModeImpl.fromJson;

  @override
  bool get enabled;
  @override
  DateTime get quietUntil;
  @override
  Duration get duration;

  /// Create a copy of QuietMode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuietModeImplCopyWith<_$QuietModeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
