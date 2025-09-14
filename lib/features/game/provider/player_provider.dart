import 'package:flutter/foundation.dart';
import '../models/player_model.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerModel? _currentPlayer;
  bool _isHost = false;
  String? _currentGameId;

  // Getters
  PlayerModel? get currentPlayer => _currentPlayer;
  bool get isHost => _isHost;
  String? get currentGameId => _currentGameId;
  bool get hasPlayer => _currentPlayer != null;
  bool get isInGame => _currentGameId != null && _currentPlayer != null;

  // Set the current player (used when hosting or joining a game)
  void setCurrentPlayer(PlayerModel player, String gameId, {bool isHost = false}) {
    _currentPlayer = player;
    _currentGameId = gameId;
    _isHost = isHost;
    notifyListeners();
  }

  // Update player information
  void updatePlayer(PlayerModel updatedPlayer) {
    if (_currentPlayer != null) {
      _currentPlayer = updatedPlayer;
      notifyListeners();
    }
  }

  // Update player's inFor amount
  void updatePlayerBuyIn(int newAmount) {
    if (_currentPlayer != null) {
      _currentPlayer = _currentPlayer!.copyWith(inFor: newAmount);
      notifyListeners();
    }
  }

  // Update player's online status
  void updatePlayerOnlineStatus(bool isOnline) {
    if (_currentPlayer != null) {
      _currentPlayer = _currentPlayer!.copyWith(isOnline: isOnline);
      notifyListeners();
    }
  }

  // Update player's payment status
  void updatePlayerPaymentStatus(bool hasPaid) {
    if (_currentPlayer != null) {
      _currentPlayer = _currentPlayer!.copyWith(hasPaid: hasPaid);
      notifyListeners();
    }
  }

  // Clear current player (used when leaving game or logging out)
  void clearPlayer() {
    _currentPlayer = null;
    _currentGameId = null;
    _isHost = false;
    notifyListeners();
  }

  // Check if current player is the host of the current game
  bool isCurrentPlayerHost() {
    return _isHost && _currentPlayer?.isHost == true;
  }

  // Get player ID
  String? get playerId => _currentPlayer?.id;

  // Get player name
  String? get playerName => _currentPlayer?.name;

  // Get player's buy-in amount
  int? get playerBuyIn => _currentPlayer?.inFor;

  // Debug method
  void debugState() {
    if (kDebugMode) {
      print('PlayerProvider Debug State:');
      print('  - currentPlayer: ${_currentPlayer?.id} (${_currentPlayer?.name})');
      print('  - currentGameId: $_currentGameId');
      print('  - isHost: $_isHost');
      print('  - hasPlayer: $hasPlayer');
      print('  - isInGame: $isInGame');
    }
  }
}
