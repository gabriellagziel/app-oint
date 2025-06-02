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
  String get title => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  DateTime? get datetime => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  String get meetingType => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get currentStep => throw _privateConstructorUsedError;
  bool get isComplete => throw _privateConstructorUsedError;

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
      {String title,
      String location,
      DateTime? datetime,
      List<String> participants,
      String meetingType,
      String notes,
      String imageUrl,
      int currentStep,
      bool isComplete});
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
    Object? title = null,
    Object? location = null,
    Object? datetime = freezed,
    Object? participants = null,
    Object? meetingType = null,
    Object? notes = null,
    Object? imageUrl = null,
    Object? currentStep = null,
    Object? isComplete = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      datetime: freezed == datetime
          ? _value.datetime
          : datetime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      meetingType: null == meetingType
          ? _value.meetingType
          : meetingType // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {String title,
      String location,
      DateTime? datetime,
      List<String> participants,
      String meetingType,
      String notes,
      String imageUrl,
      int currentStep,
      bool isComplete});
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
    Object? title = null,
    Object? location = null,
    Object? datetime = freezed,
    Object? participants = null,
    Object? meetingType = null,
    Object? notes = null,
    Object? imageUrl = null,
    Object? currentStep = null,
    Object? isComplete = null,
  }) {
    return _then(_$MeetingDraftImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      datetime: freezed == datetime
          ? _value.datetime
          : datetime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      meetingType: null == meetingType
          ? _value.meetingType
          : meetingType // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingDraftImpl extends _MeetingDraft with DiagnosticableTreeMixin {
  const _$MeetingDraftImpl(
      {this.title = '',
      this.location = '',
      this.datetime,
      final List<String> participants = const [],
      this.meetingType = '',
      this.notes = '',
      this.imageUrl = '',
      this.currentStep = 0,
      this.isComplete = false})
      : _participants = participants,
        super._();

  factory _$MeetingDraftImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingDraftImplFromJson(json);

  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String location;
  @override
  final DateTime? datetime;
  final List<String> _participants;
  @override
  @JsonKey()
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @JsonKey()
  final String meetingType;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey()
  final String imageUrl;
  @override
  @JsonKey()
  final int currentStep;
  @override
  @JsonKey()
  final bool isComplete;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MeetingDraft(title: $title, location: $location, datetime: $datetime, participants: $participants, meetingType: $meetingType, notes: $notes, imageUrl: $imageUrl, currentStep: $currentStep, isComplete: $isComplete)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MeetingDraft'))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('location', location))
      ..add(DiagnosticsProperty('datetime', datetime))
      ..add(DiagnosticsProperty('participants', participants))
      ..add(DiagnosticsProperty('meetingType', meetingType))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('currentStep', currentStep))
      ..add(DiagnosticsProperty('isComplete', isComplete));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingDraftImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.datetime, datetime) ||
                other.datetime == datetime) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.meetingType, meetingType) ||
                other.meetingType == meetingType) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      location,
      datetime,
      const DeepCollectionEquality().hash(_participants),
      meetingType,
      notes,
      imageUrl,
      currentStep,
      isComplete);

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
      {final String title,
      final String location,
      final DateTime? datetime,
      final List<String> participants,
      final String meetingType,
      final String notes,
      final String imageUrl,
      final int currentStep,
      final bool isComplete}) = _$MeetingDraftImpl;
  const _MeetingDraft._() : super._();

  factory _MeetingDraft.fromJson(Map<String, dynamic> json) =
      _$MeetingDraftImpl.fromJson;

  @override
  String get title;
  @override
  String get location;
  @override
  DateTime? get datetime;
  @override
  List<String> get participants;
  @override
  String get meetingType;
  @override
  String get notes;
  @override
  String get imageUrl;
  @override
  int get currentStep;
  @override
  bool get isComplete;

  /// Create a copy of MeetingDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingDraftImplCopyWith<_$MeetingDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
