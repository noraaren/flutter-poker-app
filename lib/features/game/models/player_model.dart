import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_model.freezed.dart';
part 'player_model.g.dart';



@freezed
abstract class PlayerModel with _$PlayerModel {
  const factory PlayerModel({
    required String id,
    required String name,
    required int inFor,
    required bool isHost,
    required bool isOnline,
    required bool hasPaid,
  }) = _PlayerModel;

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);
}