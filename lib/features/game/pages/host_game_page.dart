import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/game_provider.dart';
import '../provider/player_provider.dart';
import '../models/game_model.dart';
import '../models/player_model.dart';
import '../../../core/utils/validators.dart';

class HostGamePage extends StatefulWidget {
  const HostGamePage({super.key});

  @override
  State<HostGamePage> createState() => _HostGamePageState();
}

class _HostGamePageState extends State<HostGamePage> {
  final _formKey = GlobalKey<FormState>();
  final _hostNameController = TextEditingController();
  final _buyInController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  final _venmoUsernameController = TextEditingController();
  GameType _selectedGameType = GameType.cash;
  String? _createdGameId;

  @override
  void initState() {
    super.initState();
    _buyInController.text = '100';
    _maxPlayersController.text = '8';
  }

  @override
  void dispose() {
    _hostNameController.dispose();
    _buyInController.dispose();
    _maxPlayersController.dispose();
    _venmoUsernameController.dispose();
    super.dispose();
  }

  Future<void> _hostGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final playerProvider = context.read<PlayerProvider>();
    
    setState(() {
      _createdGameId = null;
    });

    final hostId = 'host_${DateTime.now().millisecondsSinceEpoch}';
    final hostName = _hostNameController.text.trim();
    final buyIn = int.parse(_buyInController.text);

    final gameId = await gameProvider.createGame(
      hostId: hostId,
      hostName: hostName,
      buyIn: buyIn,
      maxPlayers: int.parse(_maxPlayersController.text),
      type: _selectedGameType,
      venmoUsername: _venmoUsernameController.text.trim().isNotEmpty 
          ? _venmoUsernameController.text.trim() 
          : null,
    );

    if (gameId != null) {
      // Create host player and save to PlayerProvider
      final hostPlayer = PlayerModel(
        id: hostId,
        name: hostName,
        inFor: buyIn,
        isHost: true,
        isOnline: true,
        hasPaid: false,
      );
      
      // Set the current player as the host
      playerProvider.setCurrentPlayer(hostPlayer, gameId, isHost: true);
      
      setState(() {
        _createdGameId = gameId;
      });
      
      // Start listening to the game for real-time updates
      gameProvider.startListeningToGame(gameId);
      
      // Show success dialog
      _showSuccessDialog(gameId);
    }
  }

  void _showSuccessDialog(String gameId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Created Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game ID: $gameId'),
            const SizedBox(height: 8),
            const Text('Share this Game ID with players who want to join.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to main page
            },
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/during_game');
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host a New Game'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Host Name Field
              TextFormField(
                controller: _hostNameController,
                decoration: const InputDecoration(
                  labelText: 'Host Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Buy-in Amount Field
              TextFormField(
                controller: _buyInController,
                decoration: const InputDecoration(
                  labelText: 'Buy-in Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter buy-in amount';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Max Players Field
              TextFormField(
                controller: _maxPlayersController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Players',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max players';
                  }
                  final players = int.tryParse(value);
                  if (players == null || players < 2 || players > 10) {
                    return 'Please enter 2-10 players';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Game Type Selection
              DropdownButtonFormField<GameType>(
                value: _selectedGameType,
                decoration: const InputDecoration(
                  labelText: 'Game Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.casino),
                ),
                items: GameType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGameType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Venmo Username Field
              TextFormField(
                controller: _venmoUsernameController,
                decoration: const InputDecoration(
                  labelText: 'Venmo Username (Optional)',
                  hintText: 'Enter your Venmo username for payments',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!isValidVenmoUsername(value.trim())) {
                      return 'Please enter a valid Venmo username (3-16 characters, alphanumeric and underscores only)';
                    }
                  }
                  return null;
                },
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

                  // Host Game Button
                  ElevatedButton(
                    onPressed: gameProvider.isLoading ? null : _hostGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
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
                              Text('Creating Game...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              SizedBox(width: 8),
                              Text(
                                'Host Game',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Created Game ID Display
                  if (_createdGameId != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Game Created!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Game ID: $_createdGameId'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 