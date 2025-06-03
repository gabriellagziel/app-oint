// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeetingLocation _$MeetingLocationFromJson(Map<String, dynamic> json) {
  return _MeetingLocation.fromJson(json);
}

/// @nodoc
mixin _$MeetingLocation {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get zoomLink => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// Serializes this MeetingLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingLocationCopyWith<MeetingLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingLocationCopyWith<$Res> {
  factory $MeetingLocationCopyWith(
          MeetingLocation value, $Res Function(MeetingLocation) then) =
      _$MeetingLocationCopyWithImpl<$Res, MeetingLocation>;
  @useResult
  $Res call(
      {String name,
      String address,
      double latitude,
      double longitude,
      String? zoomLink,
      String? phoneNumber});
}

/// @nodoc
class _$MeetingLocationCopyWithImpl<$Res, $Val extends MeetingLocation>
    implements $MeetingLocationCopyWith<$Res> {
  _$MeetingLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? zoomLink = freezed,
    Object? phoneNumber = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      zoomLink: freezed == zoomLink
          ? _value.zoomLink
          : zoomLink // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingLocationImplCopyWith<$Res>
    implements $MeetingLocationCopyWith<$Res> {
  factory _$$MeetingLocationImplCopyWith(_$MeetingLocationImpl value,
          $Res Function(_$MeetingLocationImpl) then) =
      __$$MeetingLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String address,
      double latitude,
      double longitude,
      String? zoomLink,
      String? phoneNumber});
}

/// @nodoc
class __$$MeetingLocationImplCopyWithImpl<$Res>
    extends _$MeetingLocationCopyWithImpl<$Res, _$MeetingLocationImpl>
    implements _$$MeetingLocationImplCopyWith<$Res> {
  __$$MeetingLocationImplCopyWithImpl(
      _$MeetingLocationImpl _value, $Res Function(_$MeetingLocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? zoomLink = freezed,
    Object? phoneNumber = freezed,
  }) {
    return _then(_$MeetingLocationImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      zoomLink: freezed == zoomLink
          ? _value.zoomLink
          : zoomLink // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingLocationImpl implements _MeetingLocation {
  const _$MeetingLocationImpl(
      {required this.name,
      required this.address,
      required this.latitude,
      required this.longitude,
      this.zoomLink,
      this.phoneNumber});

  factory _$MeetingLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingLocationImplFromJson(json);

  @override
  final String name;
  @override
  final String address;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? zoomLink;
  @override
  final String? phoneNumber;

  @override
  String toString() {
    return 'MeetingLocation(name: $name, address: $address, latitude: $latitude, longitude: $longitude, zoomLink: $zoomLink, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingLocationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.zoomLink, zoomLink) ||
                other.zoomLink == zoomLink) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, address, latitude, longitude, zoomLink, phoneNumber);

  /// Create a copy of MeetingLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingLocationImplCopyWith<_$MeetingLocationImpl> get copyWith =>
      __$$MeetingLocationImplCopyWithImpl<_$MeetingLocationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingLocationImplToJson(
      this,
    );
  }
}

abstract class _MeetingLocation implements MeetingLocation {
  const factory _MeetingLocation(
      {required final String name,
      required final String address,
      required final double latitude,
      required final double longitude,
      final String? zoomLink,
      final String? phoneNumber}) = _$MeetingLocationImpl;

  factory _MeetingLocation.fromJson(Map<String, dynamic> json) =
      _$MeetingLocationImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get zoomLink;
  @override
  String? get phoneNumber;

  /// Create a copy of MeetingLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingLocationImplCopyWith<_$MeetingLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
