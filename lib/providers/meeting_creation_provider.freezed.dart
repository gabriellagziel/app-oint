// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_creation_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MeetingCreationState {
  int get currentStep => throw _privateConstructorUsedError;
  bool get isComplete => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  MeetingType? get type => throw _privateConstructorUsedError;
  DateTime? get dateTime => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  MeetingLocation? get location => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Create a copy of MeetingCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingCreationStateCopyWith<MeetingCreationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingCreationStateCopyWith<$Res> {
  factory $MeetingCreationStateCopyWith(MeetingCreationState value,
          $Res Function(MeetingCreationState) then) =
      _$MeetingCreationStateCopyWithImpl<$Res, MeetingCreationState>;
  @useResult
  $Res call(
      {int currentStep,
      bool isComplete,
      String title,
      MeetingType? type,
      DateTime? dateTime,
      List<String> participants,
      MeetingLocation? location,
      String notes});

  $MeetingLocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$MeetingCreationStateCopyWithImpl<$Res,
        $Val extends MeetingCreationState>
    implements $MeetingCreationStateCopyWith<$Res> {
  _$MeetingCreationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingCreationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? isComplete = null,
    Object? title = null,
    Object? type = freezed,
    Object? dateTime = freezed,
    Object? participants = null,
    Object? location = freezed,
    Object? notes = null,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MeetingType?,
      dateTime: freezed == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as MeetingLocation?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of MeetingCreationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MeetingLocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $MeetingLocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MeetingCreationStateImplCopyWith<$Res>
    implements $MeetingCreationStateCopyWith<$Res> {
  factory _$$MeetingCreationStateImplCopyWith(_$MeetingCreationStateImpl value,
          $Res Function(_$MeetingCreationStateImpl) then) =
      __$$MeetingCreationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStep,
      bool isComplete,
      String title,
      MeetingType? type,
      DateTime? dateTime,
      List<String> participants,
      MeetingLocation? location,
      String notes});

  @override
  $MeetingLocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$MeetingCreationStateImplCopyWithImpl<$Res>
    extends _$MeetingCreationStateCopyWithImpl<$Res, _$MeetingCreationStateImpl>
    implements _$$MeetingCreationStateImplCopyWith<$Res> {
  __$$MeetingCreationStateImplCopyWithImpl(_$MeetingCreationStateImpl _value,
      $Res Function(_$MeetingCreationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingCreationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? isComplete = null,
    Object? title = null,
    Object? type = freezed,
    Object? dateTime = freezed,
    Object? participants = null,
    Object? location = freezed,
    Object? notes = null,
  }) {
    return _then(_$MeetingCreationStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MeetingType?,
      dateTime: freezed == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as MeetingLocation?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MeetingCreationStateImpl implements _MeetingCreationState {
  const _$MeetingCreationStateImpl(
      {this.currentStep = 0,
      this.isComplete = false,
      this.title = '',
      this.type,
      this.dateTime,
      final List<String> participants = const [],
      this.location,
      this.notes = ''})
      : _participants = participants;

  @override
  @JsonKey()
  final int currentStep;
  @override
  @JsonKey()
  final bool isComplete;
  @override
  @JsonKey()
  final String title;
  @override
  final MeetingType? type;
  @override
  final DateTime? dateTime;
  final List<String> _participants;
  @override
  @JsonKey()
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final MeetingLocation? location;
  @override
  @JsonKey()
  final String notes;

  @override
  String toString() {
    return 'MeetingCreationState(currentStep: $currentStep, isComplete: $isComplete, title: $title, type: $type, dateTime: $dateTime, participants: $participants, location: $location, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingCreationStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStep,
      isComplete,
      title,
      type,
      dateTime,
      const DeepCollectionEquality().hash(_participants),
      location,
      notes);

  /// Create a copy of MeetingCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingCreationStateImplCopyWith<_$MeetingCreationStateImpl>
      get copyWith =>
          __$$MeetingCreationStateImplCopyWithImpl<_$MeetingCreationStateImpl>(
              this, _$identity);
}

abstract class _MeetingCreationState implements MeetingCreationState {
  const factory _MeetingCreationState(
      {final int currentStep,
      final bool isComplete,
      final String title,
      final MeetingType? type,
      final DateTime? dateTime,
      final List<String> participants,
      final MeetingLocation? location,
      final String notes}) = _$MeetingCreationStateImpl;

  @override
  int get currentStep;
  @override
  bool get isComplete;
  @override
  String get title;
  @override
  MeetingType? get type;
  @override
  DateTime? get dateTime;
  @override
  List<String> get participants;
  @override
  MeetingLocation? get location;
  @override
  String get notes;

  /// Create a copy of MeetingCreationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingCreationStateImplCopyWith<_$MeetingCreationStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
