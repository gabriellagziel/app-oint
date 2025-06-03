// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeetingDraft _$MeetingDraftFromJson(Map<String, dynamic> json) {
  return _MeetingDraft.fromJson(json);
}

/// @nodoc
mixin _$MeetingDraft {
  String get uuid => throw _privateConstructorUsedError;
  DateTime get datetime => throw _privateConstructorUsedError;
  String get meetingType => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Serializes this MeetingDraft to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingDraftCopyWith<MeetingDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingDraftCopyWith<$Res> {
  factory $MeetingDraftCopyWith(
          MeetingDraft value, $Res Function(MeetingDraft) then) =
      _$MeetingDraftCopyWithImpl<$Res, MeetingDraft>;
  @useResult
  $Res call(
      {String uuid,
      DateTime datetime,
      String meetingType,
      String location,
      String notes});
}

/// @nodoc
class _$MeetingDraftCopyWithImpl<$Res, $Val extends MeetingDraft>
    implements $MeetingDraftCopyWith<$Res> {
  _$MeetingDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? datetime = null,
    Object? meetingType = null,
    Object? location = null,
    Object? notes = null,
  }) {
    return _then(_value.copyWith(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      datetime: null == datetime
          ? _value.datetime
          : datetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meetingType: null == meetingType
          ? _value.meetingType
          : meetingType // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingDraftImplCopyWith<$Res>
    implements $MeetingDraftCopyWith<$Res> {
  factory _$$MeetingDraftImplCopyWith(
          _$MeetingDraftImpl value, $Res Function(_$MeetingDraftImpl) then) =
      __$$MeetingDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uuid,
      DateTime datetime,
      String meetingType,
      String location,
      String notes});
}

/// @nodoc
class __$$MeetingDraftImplCopyWithImpl<$Res>
    extends _$MeetingDraftCopyWithImpl<$Res, _$MeetingDraftImpl>
    implements _$$MeetingDraftImplCopyWith<$Res> {
  __$$MeetingDraftImplCopyWithImpl(
      _$MeetingDraftImpl _value, $Res Function(_$MeetingDraftImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? datetime = null,
    Object? meetingType = null,
    Object? location = null,
    Object? notes = null,
  }) {
    return _then(_$MeetingDraftImpl(
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      datetime: null == datetime
          ? _value.datetime
          : datetime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meetingType: null == meetingType
          ? _value.meetingType
          : meetingType // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingDraftImpl extends _MeetingDraft with DiagnosticableTreeMixin {
  const _$MeetingDraftImpl(
      {required this.uuid,
      required this.datetime,
      required this.meetingType,
      required this.location,
      required this.notes})
      : super._();

  factory _$MeetingDraftImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingDraftImplFromJson(json);

  @override
  final String uuid;
  @override
  final DateTime datetime;
  @override
  final String meetingType;
  @override
  final String location;
  @override
  final String notes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MeetingDraft(uuid: $uuid, datetime: $datetime, meetingType: $meetingType, location: $location, notes: $notes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MeetingDraft'))
      ..add(DiagnosticsProperty('uuid', uuid))
      ..add(DiagnosticsProperty('datetime', datetime))
      ..add(DiagnosticsProperty('meetingType', meetingType))
      ..add(DiagnosticsProperty('location', location))
      ..add(DiagnosticsProperty('notes', notes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingDraftImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.datetime, datetime) ||
                other.datetime == datetime) &&
            (identical(other.meetingType, meetingType) ||
                other.meetingType == meetingType) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, uuid, datetime, meetingType, location, notes);

  /// Create a copy of MeetingDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingDraftImplCopyWith<_$MeetingDraftImpl> get copyWith =>
      __$$MeetingDraftImplCopyWithImpl<_$MeetingDraftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingDraftImplToJson(
      this,
    );
  }
}

abstract class _MeetingDraft extends MeetingDraft {
  const factory _MeetingDraft(
      {required final String uuid,
      required final DateTime datetime,
      required final String meetingType,
      required final String location,
      required final String notes}) = _$MeetingDraftImpl;
  const _MeetingDraft._() : super._();

  factory _MeetingDraft.fromJson(Map<String, dynamic> json) =
      _$MeetingDraftImpl.fromJson;

  @override
  String get uuid;
  @override
  DateTime get datetime;
  @override
  String get meetingType;
  @override
  String get location;
  @override
  String get notes;

  /// Create a copy of MeetingDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingDraftImplCopyWith<_$MeetingDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
