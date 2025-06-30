// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameModel {

 String? get id; String get hostId; String get hostName; List<PlayerModel> get players; GameStatus get status; GameType get type; int get maxPlayers; int get currentPlayers; int get buyIn; DateTime get createdAt; DateTime? get startedAt; DateTime? get endedAt; String? get winnerId; String? get venmoUsername; Map<String, dynamic>? get gameState;
/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameModelCopyWith<GameModel> get copyWith => _$GameModelCopyWithImpl<GameModel>(this as GameModel, _$identity);

  /// Serializes this GameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&const DeepCollectionEquality().equals(other.players, players)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.currentPlayers, currentPlayers) || other.currentPlayers == currentPlayers)&&(identical(other.buyIn, buyIn) || other.buyIn == buyIn)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.venmoUsername, venmoUsername) || other.venmoUsername == venmoUsername)&&const DeepCollectionEquality().equals(other.gameState, gameState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hostId,hostName,const DeepCollectionEquality().hash(players),status,type,maxPlayers,currentPlayers,buyIn,createdAt,startedAt,endedAt,winnerId,venmoUsername,const DeepCollectionEquality().hash(gameState));

@override
String toString() {
  return 'GameModel(id: $id, hostId: $hostId, hostName: $hostName, players: $players, status: $status, type: $type, maxPlayers: $maxPlayers, currentPlayers: $currentPlayers, buyIn: $buyIn, createdAt: $createdAt, startedAt: $startedAt, endedAt: $endedAt, winnerId: $winnerId, venmoUsername: $venmoUsername, gameState: $gameState)';
}


}

/// @nodoc
abstract mixin class $GameModelCopyWith<$Res>  {
  factory $GameModelCopyWith(GameModel value, $Res Function(GameModel) _then) = _$GameModelCopyWithImpl;
@useResult
$Res call({
 String? id, String hostId, String hostName, List<PlayerModel> players, GameStatus status, GameType type, int maxPlayers, int currentPlayers, int buyIn, DateTime createdAt, DateTime? startedAt, DateTime? endedAt, String? winnerId, String? venmoUsername, Map<String, dynamic>? gameState
});




}
/// @nodoc
class _$GameModelCopyWithImpl<$Res>
    implements $GameModelCopyWith<$Res> {
  _$GameModelCopyWithImpl(this._self, this._then);

  final GameModel _self;
  final $Res Function(GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? hostId = null,Object? hostName = null,Object? players = null,Object? status = null,Object? type = null,Object? maxPlayers = null,Object? currentPlayers = null,Object? buyIn = null,Object? createdAt = null,Object? startedAt = freezed,Object? endedAt = freezed,Object? winnerId = freezed,Object? venmoUsername = freezed,Object? gameState = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<PlayerModel>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GameType,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,currentPlayers: null == currentPlayers ? _self.currentPlayers : currentPlayers // ignore: cast_nullable_to_non_nullable
as int,buyIn: null == buyIn ? _self.buyIn : buyIn // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,venmoUsername: freezed == venmoUsername ? _self.venmoUsername : venmoUsername // ignore: cast_nullable_to_non_nullable
as String?,gameState: freezed == gameState ? _self.gameState : gameState // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _GameModel implements GameModel {
  const _GameModel({this.id, required this.hostId, required this.hostName, required final  List<PlayerModel> players, required this.status, required this.type, required this.maxPlayers, required this.currentPlayers, required this.buyIn, required this.createdAt, this.startedAt, this.endedAt, this.winnerId, this.venmoUsername, final  Map<String, dynamic>? gameState}): _players = players,_gameState = gameState;
  factory _GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

@override final  String? id;
@override final  String hostId;
@override final  String hostName;
 final  List<PlayerModel> _players;
@override List<PlayerModel> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

@override final  GameStatus status;
@override final  GameType type;
@override final  int maxPlayers;
@override final  int currentPlayers;
@override final  int buyIn;
@override final  DateTime createdAt;
@override final  DateTime? startedAt;
@override final  DateTime? endedAt;
@override final  String? winnerId;
@override final  String? venmoUsername;
 final  Map<String, dynamic>? _gameState;
@override Map<String, dynamic>? get gameState {
  final value = _gameState;
  if (value == null) return null;
  if (_gameState is EqualUnmodifiableMapView) return _gameState;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameModelCopyWith<_GameModel> get copyWith => __$GameModelCopyWithImpl<_GameModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&const DeepCollectionEquality().equals(other._players, _players)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.currentPlayers, currentPlayers) || other.currentPlayers == currentPlayers)&&(identical(other.buyIn, buyIn) || other.buyIn == buyIn)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.venmoUsername, venmoUsername) || other.venmoUsername == venmoUsername)&&const DeepCollectionEquality().equals(other._gameState, _gameState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hostId,hostName,const DeepCollectionEquality().hash(_players),status,type,maxPlayers,currentPlayers,buyIn,createdAt,startedAt,endedAt,winnerId,venmoUsername,const DeepCollectionEquality().hash(_gameState));

@override
String toString() {
  return 'GameModel(id: $id, hostId: $hostId, hostName: $hostName, players: $players, status: $status, type: $type, maxPlayers: $maxPlayers, currentPlayers: $currentPlayers, buyIn: $buyIn, createdAt: $createdAt, startedAt: $startedAt, endedAt: $endedAt, winnerId: $winnerId, venmoUsername: $venmoUsername, gameState: $gameState)';
}


}

/// @nodoc
abstract mixin class _$GameModelCopyWith<$Res> implements $GameModelCopyWith<$Res> {
  factory _$GameModelCopyWith(_GameModel value, $Res Function(_GameModel) _then) = __$GameModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String hostId, String hostName, List<PlayerModel> players, GameStatus status, GameType type, int maxPlayers, int currentPlayers, int buyIn, DateTime createdAt, DateTime? startedAt, DateTime? endedAt, String? winnerId, String? venmoUsername, Map<String, dynamic>? gameState
});




}
/// @nodoc
class __$GameModelCopyWithImpl<$Res>
    implements _$GameModelCopyWith<$Res> {
  __$GameModelCopyWithImpl(this._self, this._then);

  final _GameModel _self;
  final $Res Function(_GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? hostId = null,Object? hostName = null,Object? players = null,Object? status = null,Object? type = null,Object? maxPlayers = null,Object? currentPlayers = null,Object? buyIn = null,Object? createdAt = null,Object? startedAt = freezed,Object? endedAt = freezed,Object? winnerId = freezed,Object? venmoUsername = freezed,Object? gameState = freezed,}) {
  return _then(_GameModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<PlayerModel>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GameType,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,currentPlayers: null == currentPlayers ? _self.currentPlayers : currentPlayers // ignore: cast_nullable_to_non_nullable
as int,buyIn: null == buyIn ? _self.buyIn : buyIn // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,venmoUsername: freezed == venmoUsername ? _self.venmoUsername : venmoUsername // ignore: cast_nullable_to_non_nullable
as String?,gameState: freezed == gameState ? _self._gameState : gameState // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
