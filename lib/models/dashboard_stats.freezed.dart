// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  int get totalMeetingsLastMonth => throw _privateConstructorUsedError;
  int get newClients => throw _privateConstructorUsedError;
  int get returningClients => throw _privateConstructorUsedError;
  int get inactiveClients => throw _privateConstructorUsedError;
  List<WeeklyMeetingData> get weeklyMeetings =>
      throw _privateConstructorUsedError;

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
          DashboardStats value, $Res Function(DashboardStats) then) =
      _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call(
      {int totalMeetingsLastMonth,
      int newClients,
      int returningClients,
      int inactiveClients,
      List<WeeklyMeetingData> weeklyMeetings});
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalMeetingsLastMonth = null,
    Object? newClients = null,
    Object? returningClients = null,
    Object? inactiveClients = null,
    Object? weeklyMeetings = null,
  }) {
    return _then(_value.copyWith(
      totalMeetingsLastMonth: null == totalMeetingsLastMonth
          ? _value.totalMeetingsLastMonth
          : totalMeetingsLastMonth // ignore: cast_nullable_to_non_nullable
              as int,
      newClients: null == newClients
          ? _value.newClients
          : newClients // ignore: cast_nullable_to_non_nullable
              as int,
      returningClients: null == returningClients
          ? _value.returningClients
          : returningClients // ignore: cast_nullable_to_non_nullable
              as int,
      inactiveClients: null == inactiveClients
          ? _value.inactiveClients
          : inactiveClients // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyMeetings: null == weeklyMeetings
          ? _value.weeklyMeetings
          : weeklyMeetings // ignore: cast_nullable_to_non_nullable
              as List<WeeklyMeetingData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(_$DashboardStatsImpl value,
          $Res Function(_$DashboardStatsImpl) then) =
      __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalMeetingsLastMonth,
      int newClients,
      int returningClients,
      int inactiveClients,
      List<WeeklyMeetingData> weeklyMeetings});
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
      _$DashboardStatsImpl _value, $Res Function(_$DashboardStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalMeetingsLastMonth = null,
    Object? newClients = null,
    Object? returningClients = null,
    Object? inactiveClients = null,
    Object? weeklyMeetings = null,
  }) {
    return _then(_$DashboardStatsImpl(
      totalMeetingsLastMonth: null == totalMeetingsLastMonth
          ? _value.totalMeetingsLastMonth
          : totalMeetingsLastMonth // ignore: cast_nullable_to_non_nullable
              as int,
      newClients: null == newClients
          ? _value.newClients
          : newClients // ignore: cast_nullable_to_non_nullable
              as int,
      returningClients: null == returningClients
          ? _value.returningClients
          : returningClients // ignore: cast_nullable_to_non_nullable
              as int,
      inactiveClients: null == inactiveClients
          ? _value.inactiveClients
          : inactiveClients // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyMeetings: null == weeklyMeetings
          ? _value._weeklyMeetings
          : weeklyMeetings // ignore: cast_nullable_to_non_nullable
              as List<WeeklyMeetingData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl(
      {required this.totalMeetingsLastMonth,
      required this.newClients,
      required this.returningClients,
      required this.inactiveClients,
      required final List<WeeklyMeetingData> weeklyMeetings})
      : _weeklyMeetings = weeklyMeetings;

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  @override
  final int totalMeetingsLastMonth;
  @override
  final int newClients;
  @override
  final int returningClients;
  @override
  final int inactiveClients;
  final List<WeeklyMeetingData> _weeklyMeetings;
  @override
  List<WeeklyMeetingData> get weeklyMeetings {
    if (_weeklyMeetings is EqualUnmodifiableListView) return _weeklyMeetings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyMeetings);
  }

  @override
  String toString() {
    return 'DashboardStats(totalMeetingsLastMonth: $totalMeetingsLastMonth, newClients: $newClients, returningClients: $returningClients, inactiveClients: $inactiveClients, weeklyMeetings: $weeklyMeetings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.totalMeetingsLastMonth, totalMeetingsLastMonth) ||
                other.totalMeetingsLastMonth == totalMeetingsLastMonth) &&
            (identical(other.newClients, newClients) ||
                other.newClients == newClients) &&
            (identical(other.returningClients, returningClients) ||
                other.returningClients == returningClients) &&
            (identical(other.inactiveClients, inactiveClients) ||
                other.inactiveClients == inactiveClients) &&
            const DeepCollectionEquality()
                .equals(other._weeklyMeetings, _weeklyMeetings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalMeetingsLastMonth,
      newClients,
      returningClients,
      inactiveClients,
      const DeepCollectionEquality().hash(_weeklyMeetings));

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(
      this,
    );
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats(
          {required final int totalMeetingsLastMonth,
          required final int newClients,
          required final int returningClients,
          required final int inactiveClients,
          required final List<WeeklyMeetingData> weeklyMeetings}) =
      _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override
  int get totalMeetingsLastMonth;
  @override
  int get newClients;
  @override
  int get returningClients;
  @override
  int get inactiveClients;
  @override
  List<WeeklyMeetingData> get weeklyMeetings;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyMeetingData _$WeeklyMeetingDataFromJson(Map<String, dynamic> json) {
  return _WeeklyMeetingData.fromJson(json);
}

/// @nodoc
mixin _$WeeklyMeetingData {
  DateTime get weekStart => throw _privateConstructorUsedError;
  int get meetingCount => throw _privateConstructorUsedError;

  /// Serializes this WeeklyMeetingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyMeetingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyMeetingDataCopyWith<WeeklyMeetingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyMeetingDataCopyWith<$Res> {
  factory $WeeklyMeetingDataCopyWith(
          WeeklyMeetingData value, $Res Function(WeeklyMeetingData) then) =
      _$WeeklyMeetingDataCopyWithImpl<$Res, WeeklyMeetingData>;
  @useResult
  $Res call({DateTime weekStart, int meetingCount});
}

/// @nodoc
class _$WeeklyMeetingDataCopyWithImpl<$Res, $Val extends WeeklyMeetingData>
    implements $WeeklyMeetingDataCopyWith<$Res> {
  _$WeeklyMeetingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyMeetingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? meetingCount = null,
  }) {
    return _then(_value.copyWith(
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meetingCount: null == meetingCount
          ? _value.meetingCount
          : meetingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyMeetingDataImplCopyWith<$Res>
    implements $WeeklyMeetingDataCopyWith<$Res> {
  factory _$$WeeklyMeetingDataImplCopyWith(_$WeeklyMeetingDataImpl value,
          $Res Function(_$WeeklyMeetingDataImpl) then) =
      __$$WeeklyMeetingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime weekStart, int meetingCount});
}

/// @nodoc
class __$$WeeklyMeetingDataImplCopyWithImpl<$Res>
    extends _$WeeklyMeetingDataCopyWithImpl<$Res, _$WeeklyMeetingDataImpl>
    implements _$$WeeklyMeetingDataImplCopyWith<$Res> {
  __$$WeeklyMeetingDataImplCopyWithImpl(_$WeeklyMeetingDataImpl _value,
      $Res Function(_$WeeklyMeetingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyMeetingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? meetingCount = null,
  }) {
    return _then(_$WeeklyMeetingDataImpl(
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meetingCount: null == meetingCount
          ? _value.meetingCount
          : meetingCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyMeetingDataImpl implements _WeeklyMeetingData {
  const _$WeeklyMeetingDataImpl(
      {required this.weekStart, required this.meetingCount});

  factory _$WeeklyMeetingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyMeetingDataImplFromJson(json);

  @override
  final DateTime weekStart;
  @override
  final int meetingCount;

  @override
  String toString() {
    return 'WeeklyMeetingData(weekStart: $weekStart, meetingCount: $meetingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyMeetingDataImpl &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.meetingCount, meetingCount) ||
                other.meetingCount == meetingCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, weekStart, meetingCount);

  /// Create a copy of WeeklyMeetingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyMeetingDataImplCopyWith<_$WeeklyMeetingDataImpl> get copyWith =>
      __$$WeeklyMeetingDataImplCopyWithImpl<_$WeeklyMeetingDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyMeetingDataImplToJson(
      this,
    );
  }
}

abstract class _WeeklyMeetingData implements WeeklyMeetingData {
  const factory _WeeklyMeetingData(
      {required final DateTime weekStart,
      required final int meetingCount}) = _$WeeklyMeetingDataImpl;

  factory _WeeklyMeetingData.fromJson(Map<String, dynamic> json) =
      _$WeeklyMeetingDataImpl.fromJson;

  @override
  DateTime get weekStart;
  @override
  int get meetingCount;

  /// Create a copy of WeeklyMeetingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyMeetingDataImplCopyWith<_$WeeklyMeetingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
