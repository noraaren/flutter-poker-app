import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/game_id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../models/game_model.dart';
import '../models/player_model.dart';

class GameProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  
  GameProvider(this._firebaseService);

  GameModel? _currentGame;
  String? _currentGameId;
  bool _isLoading = false;
  String? _error;

  GameModel? get currentGame => _currentGame;
  String? get currentGameId => _currentGameId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create a new game
  Future<String?> createGame({
    required String hostId,
    required String hostName,
    required int buyIn,
    required int maxPlayers,
    required GameType type,
    String? venmoUsername,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Generate a custom 7-character game ID
      String gameId;
      bool isUnique = false;
      int attempts = 0;
      do {
        gameId = GameIdGenerator.generateGameId();
        final existingGame = await _firebaseService.games.doc(gameId).get();
        isUnique = !existingGame.exists;
        attempts++;
        if (attempts > 10) {
          throw Exception('Unable to generate unique game ID');
        }
      } while (!isUnique);

      // Create host player using PlayerModel
      final hostPlayer = PlayerModel(
        id: hostId,
        name: hostName,
        inFor: buyIn,
        isHost: true,
        isOnline: true,
        hasPaid: false,
      );

      final gameData = {
        'gameId': gameId,
        'hostId': hostId,
        'hostName': hostName,
        'players': [hostPlayer.toJson()],
        'status': GameStatus.waiting.name,
        'type': type.name,
        'maxPlayers': maxPlayers,
        'currentPlayers': 1,
        'buyIn': buyIn,
        'createdAt': FieldValue.serverTimestamp(),
        'gameState': {},
        if (venmoUsername != null && venmoUsername.isNotEmpty) 'venmoUsername': venmoUsername,
      };

      await _firebaseService.games.doc(gameId).set(gameData);

      _setLoading(false);
      return gameId;
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
      // Clean and format the game ID
      final formattedGameId = GameIdGenerator.formatGameId(gameId);
      
      // Validate the game ID format
      if (!GameIdGenerator.isValidGameId(formattedGameId)) {
        throw Exception('Invalid game ID format');
      }
      
      final gameRef = _firebaseService.games.doc(formattedGameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) {
        throw Exception('Game not found');
      }

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final players = List<Map<String, dynamic>>.from(gameData['players']);

      // Check if player is already in the game
      if (players.any((existingPlayer) => existingPlayer['id'] == playerId)) {
        throw Exception('Already in this game');
      }

      // Check if game is full
      if (players.length >= gameData['maxPlayers']) {
        throw Exception('Game is full');
      }

      // Create player using PlayerModel
      final newPlayer = PlayerModel(
        id: playerId,
        name: playerName,
        inFor: buyIn,
        isHost: false,
        isOnline: true,
        hasPaid: false,
      );
      
      players.add(newPlayer.toJson());

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

  // Start listening to game updates (for real-time sync)
  StreamSubscription<DocumentSnapshot>? _gameSubscription;
  
  void startListeningToGame(String gameId) {
    _gameSubscription?.cancel();
    _currentGameId = gameId; // Store the current game ID
    final gameRef = _firebaseService.games.doc(gameId);
    
    print('Starting to listen to game: $gameId'); // Debug log
    
    _gameSubscription = gameRef.snapshots().listen(
      (snapshot) {
        print('Game snapshot received for $gameId: exists=${snapshot.exists}'); // Debug log
        if (snapshot.exists) {
          try {
            print('Raw Firestore data: ${snapshot.data()}'); // Debug log
            _currentGame = GameModel.fromFirestore(snapshot);
            print('Game data loaded successfully: ${_currentGame?.id}'); // Debug log
            notifyListeners();
          } catch (e, stackTrace) {
            print('Error parsing game data: $e'); // Debug log
            print('Stack trace: $stackTrace'); // Debug log
            _setError('Failed to parse game data: $e');
          }
        } else {
          print('Game document does not exist: $gameId'); // Debug log
          _setError('Game not found');
        }
      },
      onError: (error) {
        print('Game listener error: $error'); // Debug log
        _setError('Failed to sync game state: $error');
      },
    );
  }

  // Stop listening to game updates
  void stopListeningToGame() {
    _gameSubscription?.cancel();
    _gameSubscription = null;
  }

  // Restart listening to current game
  void restartListening() {
    if (_currentGameId != null) {
      startListeningToGame(_currentGameId!);
    }
  }

  // Debug method to check provider state
  void debugState() {
    print('GameProvider Debug State:');
    print('  - currentGameId: $_currentGameId');
    print('  - currentGame: ${_currentGame?.id}');
    print('  - isLoading: $_isLoading');
    print('  - error: $_error');
    print('  - hasSubscription: ${_gameSubscription != null}');
  }

  // End game (host only)
  Future<bool> endGame(String gameId) async {
    _setLoading(true);
    _clearError();

    try {
      final gameRef = _firebaseService.games.doc(gameId);
      await gameRef.update({
        'status': GameStatus.finished.name,
        'endedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Leave game (player only)
  Future<bool> leaveGame(String gameId, String playerId) async {
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
      
      // Remove player from the list
      players.removeWhere((player) => player['id'] == playerId);
      
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

  // Update player status (online/offline)
  Future<bool> updatePlayerStatus(String gameId, String playerId, bool isOnline) async {
    try {
      final gameRef = _firebaseService.games.doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) {
        throw Exception('Game not found');
      }

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final players = List<Map<String, dynamic>>.from(gameData['players']);
      
      // Find and update player
      final playerIndex = players.indexWhere((player) => player['id'] == playerId);
      if (playerIndex != -1) {
        players[playerIndex]['isOnline'] = isOnline;
        
        await gameRef.update({
          'players': players,
        });
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update player buy-in amount
  Future<bool> updatePlayerBuyIn(String gameId, String playerId, int newAmount) async {
    try {
      final gameRef = _firebaseService.games.doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) {
        throw Exception('Game not found');
      }

      final gameData = gameDoc.data() as Map<String, dynamic>;
      final players = List<Map<String, dynamic>>.from(gameData['players']);
      
      // Find and update player
      final playerIndex = players.indexWhere((player) => player['id'] == playerId);
      if (playerIndex != -1) {
        players[playerIndex]['inFor'] = newAmount;
        
        await gameRef.update({
          'players': players,
        });
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Set Venmo username (host only)
  Future<bool> setVenmoUsername(String gameId, String venmoUsername) async {
    try {
      final gameRef = _firebaseService.games.doc(gameId);
      await gameRef.update({
        'venmoUsername': venmoUsername,
      });
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update Venmo username (host only) - with validation
  Future<bool> updateVenmoUsername(String gameId, String venmoUsername) async {
    if (venmoUsername.trim().isEmpty) {
      _setError('Venmo username cannot be empty');
      return false;
    }
    
    if (!isValidVenmoUsername(venmoUsername.trim())) {
      _setError('Please enter a valid Venmo username (3-16 characters, alphanumeric and underscores only)');
      return false;
    }
    
    return await setVenmoUsername(gameId, venmoUsername.trim());
  }

  // Manually fetch game data (fallback method)
  Future<bool> fetchGame(String gameId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final gameRef = _firebaseService.games.doc(gameId);
      final snapshot = await gameRef.get();
      
      if (snapshot.exists) {
        print('Fetching game data for: $gameId'); // Debug log
        print('Raw Firestore data: ${snapshot.data()}'); // Debug log
        _currentGame = GameModel.fromFirestore(snapshot);
        print('Game data fetched successfully: ${_currentGame?.id}'); // Debug log
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        print('Game document does not exist when fetching: $gameId'); // Debug log
        _setError('Game not found');
        _setLoading(false);
        return false;
      }
    } catch (e, stackTrace) {
      print('Error fetching game data: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      _setError('Failed to fetch game: $e');
      _setLoading(false);
      return false;
    }
  }

  // Clear current game data
  void clearGame() {
    _currentGame = null;
    _currentGameId = null;
    _gameSubscription?.cancel();
    _gameSubscription = null;
    _clearError();
    notifyListeners();
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

  @override
  void dispose() {
    _gameSubscription?.cancel();
    super.dispose();
  }
}