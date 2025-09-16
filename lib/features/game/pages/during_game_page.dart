import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/venmo_service.dart';
import '../models/game_model.dart';
import '../models/player_model.dart';
import '../provider/game_provider.dart';
import '../provider/player_provider.dart';

class DuringGamePage extends StatefulWidget {
  const DuringGamePage({super.key});

  @override
  State<DuringGamePage> createState() => _DuringGamePageState();
}

class _DuringGamePageState extends State<DuringGamePage> {
  final _topOffController = TextEditingController();
  final _venmoUsernameController = TextEditingController();
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default values, will be updated when game data loads
    _topOffController.text = '100';
  }

  void _updateControllersFromGame(GameModel game) {
    // Update top-off amount based on game buy-in
    if (_topOffController.text == '100') {
      _topOffController.text = game.buyIn.toString();
    }
    
    // Update Venmo username if available and not already set
    if (game.venmoUsername != null && 
        game.venmoUsername!.isNotEmpty && 
        _venmoUsernameController.text.isEmpty) {
      _venmoUsernameController.text = game.venmoUsername!;
    }
  }

  @override
  void dispose() {
    _topOffController.dispose();
    _venmoUsernameController.dispose();
    super.dispose();
  }

  int _getTotalBuyIns(List<PlayerModel> players) => players.fold(0, (sum, player) => sum + player.inFor);

  Future<void> _handleTopOff(GameModel game) async {
    if (_topOffController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a top-off amount');
      return;
    }

    final amount = int.tryParse(_topOffController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    if (game.venmoUsername == null || game.venmoUsername!.isEmpty) {
      _showErrorSnackBar('Host has not set their Venmo username');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final success = await VenmoService.launchVenmoTransaction(
        venmoUsername: game.venmoUsername!,
        amount: amount.toDouble(),
        note: 'Poker game top-off - ${game.id}',
        context: context,
        transactionType: VenmoTransactionType.pay,
      );

      if (success) {
        _showSuccessSnackBar('Venmo opened for payment of \$${amount.toStringAsFixed(2)}');
      } else {
        _showErrorSnackBar('Failed to open Venmo. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _showTopOffDialog(GameModel game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Buy-in / Top-off'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _topOffController,
              decoration: const InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            if (game.venmoUsername != null) ...[
              TextField(
                controller: _venmoUsernameController,
                decoration: const InputDecoration(
                  labelText: 'Host Venmo Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                enabled: false, // Read-only since it's set by host
              ),
            ] else ...[
              const Text(
                'Host has not set their Venmo username',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: game.venmoUsername != null ? () => _handleTopOff(game) : null,
            child: _isProcessingPayment
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Pay via Venmo'),
          ),
        ],
      ),
    );
  }

  void _showEndGameDialog(GameModel game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Game'),
        content: const Text('Are you sure you want to end the game for all players?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final gameProvider = context.read<GameProvider>();
              final success = await gameProvider.endGame(game.id!);
              if (success) {
                _showSuccessSnackBar('Game ended successfully');
                Navigator.of(context).pushReplacementNamed('/end_game');
              } else {
                _showErrorSnackBar('Failed to end game');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Game'),
          ),
        ],
      ),
    );
  }

  void _showLeaveGameDialog(GameModel game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Game'),
        content: const Text('Are you sure you want to leave this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final gameProvider = context.read<GameProvider>();
              final playerProvider = context.read<PlayerProvider>();
              final success = await gameProvider.leaveGame(game.id!, playerProvider.playerId!);
              if (success) {
                gameProvider.clearGame();
                Navigator.of(context).pop(); // Go back to main page
                _showSuccessSnackBar('Left game successfully');
              } else {
                _showErrorSnackBar('Failed to leave game');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave Game'),
          ),
        ],
      ),
    );
  }

  void _showVenmoUsernameDialog(GameModel game) {
    final venmoController = TextEditingController(text: game.venmoUsername ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Venmo Username'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your Venmo username for receiving payments:'),
            const SizedBox(height: 16),
            TextField(
              controller: venmoController,
              decoration: const InputDecoration(
                labelText: 'Venmo Username',
                hintText: 'e.g., john_doe123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final gameProvider = context.read<GameProvider>();
              final success = await gameProvider.updateVenmoUsername(
                game.id!, 
                venmoController.text.trim(),
              );
              if (success) {
                _showSuccessSnackBar('Venmo username updated successfully');
              } else {
                _showErrorSnackBar(gameProvider.error ?? 'Failed to update Venmo username');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, PlayerProvider>(
      builder: (context, gameProvider, playerProvider, child) {
        final game = gameProvider.currentGame;
        final player = playerProvider.currentPlayer;
        
        // Check if player exists
        if (player == null) {
          return Scaffold(
            appBar: AppBar(title: Text('No Player')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No player data available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        
        print('DuringGamePage - GameProvider state: isLoading=${gameProvider.isLoading}, error=${gameProvider.error}, game=${game?.id}'); // Debug log
        
        if (gameProvider.isLoading && game == null) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (gameProvider.error != null && game == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${gameProvider.error}'),
                  ElevatedButton(
                    onPressed: () => gameProvider.clearGame(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: Text('No Game')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No game data available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Try to fetch game data manually
                      print('Attempting to fetch game data manually'); // Debug log
                      final gameProvider = context.read<GameProvider>();
                      gameProvider.debugState(); // Debug log
                      if (gameProvider.currentGameId != null) {
                        await gameProvider.fetchGame(gameProvider.currentGameId!);
                      } else {
                        print('No current game ID available for retry'); // Debug log
                      }
                    },
                    child: Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Update controllers with game data
        _updateControllersFromGame(game);
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Game: ${game.id}'),
            backgroundColor: context.watch<PlayerProvider>().isHost ? Colors.green[700] : Colors.blue[700],
            foregroundColor: Colors.white,
            actions: [
              if (context.watch<PlayerProvider>().isHost) ...[
                IconButton(
                  onPressed: () => _showVenmoUsernameDialog(game),
                  icon: const Icon(Icons.payment),
                  tooltip: 'Update Venmo Username',
                ),
                IconButton(
                  onPressed: () => _showEndGameDialog(game),
                  icon: const Icon(Icons.stop),
                  tooltip: 'End Game',
                ),
              ] else
                IconButton(
                  onPressed: () => _showLeaveGameDialog(game),
                  icon: const Icon(Icons.exit_to_app),
                  tooltip: 'Leave Game',
                ),
            ],
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game Stats Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Stats',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.group,
                          label: 'Players',
                          value: '${game.currentPlayers}/${game.maxPlayers}',
                        ),
                        _buildStatItem(
                          icon: Icons.attach_money,
                          label: 'Total Buy-ins',
                          value: '\$${_getTotalBuyIns(game.players).toStringAsFixed(0)}',
                        ),
                        _buildStatItem(
                          icon: Icons.casino,
                          label: 'Buy-in',
                          value: '\$${game.buyIn}',
                        ),
                        _buildStatItem(
                          icon: Icons.payment,
                          label: 'Venmo',
                          value: game.venmoUsername != null && game.venmoUsername!.isNotEmpty 
                              ? '@${game.venmoUsername}' 
                              : 'Not Set',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Players List
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Players',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: game.players.length,
                          itemBuilder: (context, index) {
                            final player = game.players[index];
                            return _buildPlayerTile(player);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTopOffDialog(game),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Buy-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (context.watch<PlayerProvider>().isHost)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showEndGameDialog(game),
                      icon: const Icon(Icons.stop),
                      label: const Text('End Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showLeaveGameDialog(game),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Leave Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue[700]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTile(PlayerModel player) {
    final playerProvider = context.read<PlayerProvider>();
    final isCurrentPlayer = player.id == playerProvider.playerId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.blue[50] : Colors.grey[50],
        border: Border.all(
          color: isCurrentPlayer ? Colors.blue : Colors.grey[300]!,
          width: isCurrentPlayer ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: player.isHost ? Colors.green[700] : Colors.blue[700],
            child: Text(
              player.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (player.isHost) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (isCurrentPlayer) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'In for: \$${player.inFor}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      player.isOnline ? Icons.circle : Icons.circle_outlined,
                      color: player.isOnline ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: player.isOnline ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
