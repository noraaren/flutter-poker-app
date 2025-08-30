import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/venmo_service.dart';
import '../../../core/utils/validators.dart';
import '../models/player_model.dart';

class EndGamePage extends StatefulWidget {
  final PlayerModel player;
  final String? hostVenmoUsername;
  final int initialBuyIn; // Initial buy-in from game data

  const EndGamePage({
    super.key,
    required this.player,
    this.hostVenmoUsername,
    required this.initialBuyIn,
  });

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
    // Pre-fill with host's Venmo username if available
    if (widget.hostVenmoUsername != null) {
      _venmoUsernameController.text = widget.hostVenmoUsername!;
    }
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
      
      // Since all payments were made beforehand, the difference is just the final stack
      // Players only request money if they have chips left, or owe nothing if they're even
      final difference = finalStack;

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

    if (_difference! > 0) {
      // Player has chips left - request payment from host
      final note = "Poker winnings for ${widget.player.name}";
      await VenmoService.requestWithVenmo(
        venmoUsername: venmoUsername,
        amount: _difference!,
        note: note,
        context: context,
      );
    } else {
      // Player is even (no chips left) - no transaction needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Break even! No payment needed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'Player: ${widget.player.name}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'In For: \$${widget.player.inFor}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Initial Buy-in: \$${widget.initialBuyIn}',
                        style: Theme.of(context).textTheme.titleMedium,
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
                          'Amount to Request: \$${_difference!.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _difference! > 0 ? Colors.green[700] : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _difference! > 0
                              ? 'You have chips left! Request payment from host.'
                              : 'Break even! No payment needed.',
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
                  onPressed: _difference! > 0 ? _handleVenmoTransaction : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Request Payment via Venmo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 