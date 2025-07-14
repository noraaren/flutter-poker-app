import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'player_model.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

@freezed
abstract class GameModel with _$GameModel {
  const factory GameModel({
    String? id,
    required String hostId,
    required String hostName,
    required List<PlayerModel> players,
    required GameStatus status,
    required GameType type,
    required int maxPlayers,
    required int currentPlayers,
    required int buyIn,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    String? winnerId,
    String? venmoUsername,
    Map<String, dynamic>? gameState,
  }) = _GameModel;

  factory GameModel.fromJson(Map<String, dynamic> json) =>
      _$GameModelFromJson(json);

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }
}

enum GameStatus {
  @JsonValue('waiting')
  waiting,
  @JsonValue('playing')
  playing,
  @JsonValue('finished')
  finished,
  @JsonValue('cancelled')
  cancelled,
}

enum GameType {
  @JsonValue('cash')
  cash,
  @JsonValue('tournament')
  tournament,
}