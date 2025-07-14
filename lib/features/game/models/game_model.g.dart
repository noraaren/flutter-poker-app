// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameModel _$GameModelFromJson(Map<String, dynamic> json) => _GameModel(
  id: json['id'] as String?,
  hostId: json['hostId'] as String,
  hostName: json['hostName'] as String,
  players: (json['players'] as List<dynamic>)
      .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: $enumDecode(_$GameStatusEnumMap, json['status']),
  type: $enumDecode(_$GameTypeEnumMap, json['type']),
  maxPlayers: (json['maxPlayers'] as num).toInt(),
  currentPlayers: (json['currentPlayers'] as num).toInt(),
  buyIn: (json['buyIn'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  winnerId: json['winnerId'] as String?,
  venmoUsername: json['venmoUsername'] as String?,
  gameState: json['gameState'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$GameModelToJson(_GameModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hostId': instance.hostId,
      'hostName': instance.hostName,
      'players': instance.players,
      'status': _$GameStatusEnumMap[instance.status]!,
      'type': _$GameTypeEnumMap[instance.type]!,
      'maxPlayers': instance.maxPlayers,
      'currentPlayers': instance.currentPlayers,
      'buyIn': instance.buyIn,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'winnerId': instance.winnerId,
      'venmoUsername': instance.venmoUsername,
      'gameState': instance.gameState,
    };

const _$GameStatusEnumMap = {
  GameStatus.waiting: 'waiting',
  GameStatus.playing: 'playing',
  GameStatus.finished: 'finished',
  GameStatus.cancelled: 'cancelled',
};

const _$GameTypeEnumMap = {
  GameType.cash: 'cash',
  GameType.tournament: 'tournament',
};
