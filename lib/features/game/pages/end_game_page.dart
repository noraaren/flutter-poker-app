import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/venmo_service.dart';
import '../../../core/utils/validators.dart';
import '../provider/game_provider.dart';
import '../provider/player_provider.dart';

class EndGamePage extends StatefulWidget {
  const EndGamePage({super.key});

  @override
  State<EndGamePage> createState() => _EndGamePageState();
}

class _EndGamePageState extends State<EndGamePage> {
  final _formKey = GlobalKey<FormState>();
  final _finalStackController = TextEditingController();
  final _venmoUsernameController = TextEditingController();
  
  double? _finalStack;
  double? _difference;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    // Will be populated from game data via provider
  }

  @override
  void dispose() {
    _finalStackController.dispose();
    _venmoUsernameController.dispose();
    super.dispose();
  }

  void _calculateDifference() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });

      final finalStack = double.parse(_finalStackController.text);
      
      // Calculate the difference between final stack and what they put in (inFor)
      // This determines if they made money, lost money, or broke even
      final playerProvider = context.read<PlayerProvider>();
      final difference = finalStack - playerProvider.playerBuyIn!;

      setState(() {
        _finalStack = finalStack;
        _difference = difference;
        _isCalculating = false;
      });
    }
  }

  Future<void> _handleVenmoTransaction() async {
    if (_difference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please calculate the difference first'),
        ),
      );
      return;
    }

    final venmoUsername = _venmoUsernameController.text.trim();
    if (!isValidVenmoUsername(venmoUsername)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Venmo username'),
        ),
      );
      return;
    }

    if (_finalStack! > 0) {
      // Player has chips left - request payment from host
      final playerProvider = context.read<PlayerProvider>();
      final note = _difference! > 0 
          ? "Poker winnings for ${playerProvider.playerName}"
          : "Poker payment for ${playerProvider.playerName}";
      await VenmoService.requestWithVenmo(
        venmoUsername: venmoUsername,
        amount: _finalStack!,
        note: note,
        context: context,
      );
    } else {
      // Player has no chips left - no payment needed
      final message = _difference! > 0
          ? 'You made money but have no chips left. No payment needed.'
          : _difference! < 0
              ? 'You lost money and have no chips left. No payment needed.'
              : 'You broke even with no chips left. No payment needed.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
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
        
        print('EndGamePage - GameProvider state: isLoading=${gameProvider.isLoading}, error=${gameProvider.error}, game=${game?.id}'); // Debug log
        
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
                      print('Attempting to fetch game data manually in EndGamePage'); // Debug log
                      final gameProvider = context.read<GameProvider>();
                      if (gameProvider.currentGameId != null) {
                        await gameProvider.fetchGame(gameProvider.currentGameId!);
                      } else {
                        print('No current game ID available for retry in EndGamePage'); // Debug log
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
        
        // Initialize Venmo username if not already set
        if (_venmoUsernameController.text.isEmpty && game.venmoUsername != null) {
          _venmoUsernameController.text = game.venmoUsername!;
        }
        
        // Show warning if Venmo username is not set
        if (game.venmoUsername == null || game.venmoUsername!.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Host has not set their Venmo username. Please contact the host.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          });
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('End Game'),
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Player Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Player: ${context.watch<PlayerProvider>().playerName}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'In For: \$${context.watch<PlayerProvider>().playerBuyIn}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Initial Buy-in: \$${game.buyIn}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            size: 16,
                            color: game.venmoUsername != null && game.venmoUsername!.isNotEmpty 
                                ? Colors.green 
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            game.venmoUsername != null && game.venmoUsername!.isNotEmpty 
                                ? 'Venmo: @${game.venmoUsername}' 
                                : 'Venmo: Not Set',
                            style: TextStyle(
                              color: game.venmoUsername != null && game.venmoUsername!.isNotEmpty 
                                  ? Colors.green 
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),



              // Final Stack Input
              TextFormField(
                controller: _finalStackController,
                decoration: const InputDecoration(
                  labelText: 'Final Stack (\$)',
                  hintText: 'Enter your final chip count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your final stack';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calculate Button
              ElevatedButton(
                onPressed: _isCalculating ? null : _calculateDifference,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCalculating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Calculate Difference'),
              ),
              const SizedBox(height: 24),

              // Results Section
              if (_difference != null) ...[
                Card(
                  color: _difference! > 0 ? Colors.green[50] : Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Results',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Final Stack: \$${_finalStack!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Amount to Request: \$${_finalStack!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _difference! > 0 ? Colors.green[700] : _difference! < 0 ? Colors.red[700] : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _difference! > 0
                              ? 'You made money! Request payment from host.'
                              : _difference! < 0
                                  ? 'You lost money. Request payment if you have chips left.'
                                  : 'You broke even! Request payment if you have chips left.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Venmo Username Input
                TextFormField(
                  controller: _venmoUsernameController,
                  decoration: const InputDecoration(
                    labelText: 'Host Venmo Username',
                    hintText: 'Enter host\'s Venmo username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Venmo username';
                    }
                    if (!isValidVenmoUsername(value.trim())) {
                      return 'Please enter a valid Venmo username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Venmo Transaction Button
                ElevatedButton(
                  onPressed: (_difference! > 0 || (_difference! <= 0 && _finalStack! > 0)) ? _handleVenmoTransaction : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _difference! > 0 
                        ? 'Request Winnings via Venmo'
                        : 'Request Payment via Venmo'
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
        );
      },
    );
  }
} 