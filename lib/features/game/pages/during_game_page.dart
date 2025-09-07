import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/venmo_service.dart';
import '../models/game_model.dart';
import '../models/player_model.dart';

class DuringGamePage extends StatefulWidget {
  final GameModel game;
  final PlayerModel currentPlayer;

  const DuringGamePage({
    super.key,
    required this.game,
    required this.currentPlayer,
  });

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
    _topOffController.text = widget.game.buyIn.toString();
    if (widget.game.venmoUsername != null) {
      _venmoUsernameController.text = widget.game.venmoUsername!;
    }
  }

  @override
  void dispose() {
    _topOffController.dispose();
    _venmoUsernameController.dispose();
    super.dispose();
  }

  int get _totalBuyIns => widget.game.players.fold(0, (sum, player) => sum + player.inFor);

  Future<void> _handleTopOff() async {
    if (_topOffController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a top-off amount');
      return;
    }

    final amount = int.tryParse(_topOffController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    if (widget.game.venmoUsername == null || widget.game.venmoUsername!.isEmpty) {
      _showErrorSnackBar('Host has not set their Venmo username');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final success = await VenmoService.launchVenmoTransaction(
        venmoUsername: widget.game.venmoUsername!,
        amount: amount.toDouble(),
        note: 'Poker game top-off - ${widget.game.id}',
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

  void _showTopOffDialog() {
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
            if (widget.game.venmoUsername != null) ...[
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
            onPressed: widget.game.venmoUsername != null ? _handleTopOff : null,
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

  void _showEndGameDialog() {
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
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement end game functionality
              _showSuccessSnackBar('Game ended successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Game'),
          ),
        ],
      ),
    );
  }

  void _showLeaveGameDialog() {
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
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement leave game functionality
              Navigator.of(context).pop(); // Go back to main page
              _showSuccessSnackBar('Left game successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave Game'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Game: ${widget.game.id}'),
        backgroundColor: widget.currentPlayer.isHost ? Colors.green[700] : Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (widget.currentPlayer.isHost)
            IconButton(
              onPressed: _showEndGameDialog,
              icon: const Icon(Icons.stop),
              tooltip: 'End Game',
            )
          else
            IconButton(
              onPressed: _showLeaveGameDialog,
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
                          value: '${widget.game.currentPlayers}/${widget.game.maxPlayers}',
                        ),
                        _buildStatItem(
                          icon: Icons.attach_money,
                          label: 'Total Buy-ins',
                          value: '\$${_totalBuyIns.toStringAsFixed(0)}',
                        ),
                        _buildStatItem(
                          icon: Icons.casino,
                          label: 'Buy-in',
                          value: '\$${widget.game.buyIn}',
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
                          itemCount: widget.game.players.length,
                          itemBuilder: (context, index) {
                            final player = widget.game.players[index];
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
                    onPressed: _showTopOffDialog,
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
                if (widget.currentPlayer.isHost)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showEndGameDialog,
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
                      onPressed: _showLeaveGameDialog,
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
    final isCurrentPlayer = player.id == widget.currentPlayer.id;
    
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
