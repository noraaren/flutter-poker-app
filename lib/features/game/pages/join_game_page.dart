import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/game_provider.dart';
import '../provider/player_provider.dart';
import '../models/player_model.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key});

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  final _gameIdController = TextEditingController();
  final _playerNameController = TextEditingController();
  final _buyInController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buyInController.text = '100'; // Default buy-in
  }

  @override
  void dispose() {
    _gameIdController.dispose();
    _playerNameController.dispose();
    _buyInController.dispose();
    super.dispose();
  }

  Future<void> _findGame() async {
    if (_gameIdController.text.trim().isEmpty || 
        _playerNameController.text.trim().isEmpty ||
        _buyInController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final playerProvider = context.read<PlayerProvider>();
    final playerId = 'player_${DateTime.now().millisecondsSinceEpoch}';
    final playerName = _playerNameController.text.trim();
    final buyIn = int.parse(_buyInController.text);
    final gameId = _gameIdController.text.trim();
    
    final success = await gameProvider.joinGame(
      gameId,
      playerId,
      playerName,
      buyIn,
    );

    if (success) {
      // Create player and save to PlayerProvider
      final player = PlayerModel(
        id: playerId,
        name: playerName,
        inFor: buyIn,
        isHost: false,
        isOnline: true,
        hasPaid: false,
      );
      
      // Set the current player
      playerProvider.setCurrentPlayer(player, gameId, isHost: false);
      
      // Start listening to the game for real-time updates
      gameProvider.startListeningToGame(gameId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined the game!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to during game page
      Navigator.of(context).pushReplacementNamed('/during_game');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(gameProvider.error ?? 'Failed to join game'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Player Name Field
            TextField(
              controller: _playerNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            // Game ID Field
            TextField(
              controller: _gameIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Game ID',
                hintText: 'e.g., ABC1234',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            // Buy-in Amount Field
            TextField(
              controller: _buyInController,
              decoration: const InputDecoration(
                labelText: 'Buy-in Amount (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
                // Error Display
                if (gameProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      gameProvider.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                
                if (gameProvider.error != null) const SizedBox(height: 16),
                // Find Game Button
                ElevatedButton(
                  onPressed: gameProvider.isLoading ? null : _findGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
                  child: gameProvider.isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Joining Game...'),
                          ],
                        )
                      : const Text(
                     'Find Game',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 