// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerModel {

 String get id; String get name; int get inFor; bool get isHost; bool get isOnline; bool get hasPaid;
/// Create a copy of PlayerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerModelCopyWith<PlayerModel> get copyWith => _$PlayerModelCopyWithImpl<PlayerModel>(this as PlayerModel, _$identity);

  /// Serializes this PlayerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.inFor, inFor) || other.inFor == inFor)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,inFor,isHost,isOnline,hasPaid);

@override
String toString() {
  return 'PlayerModel(id: $id, name: $name, inFor: $inFor, isHost: $isHost, isOnline: $isOnline, hasPaid: $hasPaid)';
}


}

/// @nodoc
abstract mixin class $PlayerModelCopyWith<$Res>  {
  factory $PlayerModelCopyWith(PlayerModel value, $Res Function(PlayerModel) _then) = _$PlayerModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, int inFor, bool isHost, bool isOnline, bool hasPaid
});




}
/// @nodoc
class _$PlayerModelCopyWithImpl<$Res>
    implements $PlayerModelCopyWith<$Res> {
  _$PlayerModelCopyWithImpl(this._self, this._then);

  final PlayerModel _self;
  final $Res Function(PlayerModel) _then;

/// Create a copy of PlayerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? inFor = null,Object? isHost = null,Object? isOnline = null,Object? hasPaid = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,inFor: null == inFor ? _self.inFor : inFor // ignore: cast_nullable_to_non_nullable
as int,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PlayerModel implements PlayerModel {
  const _PlayerModel({required this.id, required this.name, required this.inFor, required this.isHost, required this.isOnline, required this.hasPaid});
  factory _PlayerModel.fromJson(Map<String, dynamic> json) => _$PlayerModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  int inFor;
@override final  bool isHost;
@override final  bool isOnline;
@override final  bool hasPaid;

/// Create a copy of PlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerModelCopyWith<_PlayerModel> get copyWith => __$PlayerModelCopyWithImpl<_PlayerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.inFor, inFor) || other.inFor == inFor)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.hasPaid, hasPaid) || other.hasPaid == hasPaid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,inFor,isHost,isOnline,hasPaid);

@override
String toString() {
  return 'PlayerModel(id: $id, name: $name, inFor: $inFor, isHost: $isHost, isOnline: $isOnline, hasPaid: $hasPaid)';
}


}

/// @nodoc
abstract mixin class _$PlayerModelCopyWith<$Res> implements $PlayerModelCopyWith<$Res> {
  factory _$PlayerModelCopyWith(_PlayerModel value, $Res Function(_PlayerModel) _then) = __$PlayerModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int inFor, bool isHost, bool isOnline, bool hasPaid
});




}
/// @nodoc
class __$PlayerModelCopyWithImpl<$Res>
    implements _$PlayerModelCopyWith<$Res> {
  __$PlayerModelCopyWithImpl(this._self, this._then);

  final _PlayerModel _self;
  final $Res Function(_PlayerModel) _then;

/// Create a copy of PlayerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? inFor = null,Object? isHost = null,Object? isOnline = null,Object? hasPaid = null,}) {
  return _then(_PlayerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,inFor: null == inFor ? _self.inFor : inFor // ignore: cast_nullable_to_non_nullable
as int,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,hasPaid: null == hasPaid ? _self.hasPaid : hasPaid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
