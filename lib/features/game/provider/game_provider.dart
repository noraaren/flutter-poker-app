import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/game_model.dart';
import '../models/player_model.dart';

class GameProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  
  GameProvider(this._firebaseService);

  GameModel? _currentGame;
  List<GameModel> _availableGames = [];
  bool _isLoading = false;
  String? _error;

  GameModel? get currentGame => _currentGame;
  List<GameModel> get availableGames => _availableGames;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create a new game
  Future<String?> createGame({
    required String hostId,
    required String hostName,
    required int buyIn,
    required int maxPlayers,
    required GameType type,
  }) async {
    _setLoading(true);
    _clearError();

    try {

      final gameData = {
        'hostId': hostId,
        'hostName': hostName,
        'players': [
          {
            'id': hostId,
            'name': hostName,
            'inFor': buyIn,
            'isHost': true,
            'hasPaid': false,
            'isOnline': true,
          }
        ],
        'status': GameStatus.waiting.name,
        'type': type.name,
        'maxPlayers': maxPlayers,
        'currentPlayers': 1,
        'buyIn': buyIn,
        'createdAt': FieldValue.serverTimestamp(),
        'gameState': {},
      };

      final docRef = await _firebaseService.addDocument(
        _firebaseService.games,
        gameData,
      );

      _setLoading(false);
      return docRef.id;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Join an existing game
  Future<bool> joinGame(String gameId, String playerId, String playerName, int buyIn) async {
    _setLoading(true);
    _clearError();

    try {
      final gameRef = _firebaseService.games.doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) {
        throw Exception('Game not found');
      }

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final players = List<Map<String, dynamic>>.from(gameData['players']);

      // Check if player is already in the game
      if (players.any((player) => player['id'] == playerId)) {
        throw Exception('Already in this game');
      }

      // Check if game is full
      if (players.length >= gameData['maxPlayers']) {
        throw Exception('Game is full');
      }

      // Add player to the game
      final newPlayer = {
        'id': playerId,
        'name': playerName,
        'inFor': buyIn,
        'isHost': false,
        'hasPaid': false,
        'isOnline': true,
      };

      players.add(newPlayer);

      await gameRef.update({
        'players': players,
        'currentPlayers': players.length,
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Listen to game updates in real-time
  void listenToGame(String gameId) {
    final gameRef = _firebaseService.games.doc(gameId);
    gameRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _currentGame = GameModel.fromFirestore(snapshot);
        notifyListeners();
      }
    });
  }


  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}