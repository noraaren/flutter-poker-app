import 'package:flutter/material.dart';
import '../provider/game_provider.dart';
import '../../../core/services/firebase_service.dart';

class JoinGamePage extends StatefulWidget {
  const JoinGamePage({super.key});

  @override
  State<JoinGamePage> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGamePage> {
  final _gameIdController = TextEditingController();
  final _playerNameController = TextEditingController();
  final _buyInController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  
  late final GameProvider _gameProvider;

  @override
  void initState() {
    super.initState();
    _gameProvider = GameProvider(FirebaseService());
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
      setState(() {
        _error = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final playerId = 'player_${DateTime.now().millisecondsSinceEpoch}';
      
      final success = await _gameProvider.joinGame(
        _gameIdController.text.trim(),
        playerId,
        _playerNameController.text.trim(),
        int.parse(_buyInController.text),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the game!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _gameIdController.clear();
        _playerNameController.clear();
        _buyInController.text = '100';
      } else {
        setState(() {
          _error = _gameProvider.error ?? 'Failed to join game';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: Padding(
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
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            
            if (_error != null) const SizedBox(height: 16),
            // Find Game Button
            ElevatedButton(
              onPressed: _isLoading ? null : _findGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
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
      ),
    );
  }
} 