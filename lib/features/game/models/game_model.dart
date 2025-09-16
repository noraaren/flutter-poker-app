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
    
    // Convert Firestore timestamps to ISO string format for JSON serialization
    final convertedData = <String, dynamic>{
      'id': doc.id,
      ...data,
    };
    
    // Handle createdAt timestamp - convert to ISO string
    if (convertedData['createdAt'] is Timestamp) {
      final dateTime = (convertedData['createdAt'] as Timestamp).toDate();
      convertedData['createdAt'] = dateTime.toIso8601String();
      print('Converted createdAt: ${convertedData['createdAt']}'); // Debug log
    }
    
    // Handle startedAt timestamp - convert to ISO string
    if (convertedData['startedAt'] is Timestamp) {
      final dateTime = (convertedData['startedAt'] as Timestamp).toDate();
      convertedData['startedAt'] = dateTime.toIso8601String();
      print('Converted startedAt: ${convertedData['startedAt']}'); // Debug log
    }
    
    // Handle endedAt timestamp - convert to ISO string
    if (convertedData['endedAt'] is Timestamp) {
      final dateTime = (convertedData['endedAt'] as Timestamp).toDate();
      convertedData['endedAt'] = dateTime.toIso8601String();
      print('Converted endedAt: ${convertedData['endedAt']}'); // Debug log
    }
    
    print('Converted data before JSON parsing: $convertedData'); // Debug log
    
    return GameModel.fromJson(convertedData);
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