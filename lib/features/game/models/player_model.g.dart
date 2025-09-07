// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) => _PlayerModel(
  id: json['id'] as String,
  name: json['name'] as String,
  inFor: (json['inFor'] as num).toInt(),
  isHost: json['isHost'] as bool,
  isOnline: json['isOnline'] as bool,
  hasPaid: json['hasPaid'] as bool,
);

Map<String, dynamic> _$PlayerModelToJson(_PlayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'inFor': instance.inFor,
      'isHost': instance.isHost,
      'isOnline': instance.isOnline,
      'hasPaid': instance.hasPaid,
    };
