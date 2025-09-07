import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/game/pages/end_game_page.dart';
import 'features/game/models/player_model.dart';
import 'features/game/models/game_model.dart';
import 'features/game/pages/during_game_page.dart';

import 'features/game/pages/host_game_page.dart';
import 'features/game/pages/join_game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required for async setup
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(PokerApp());
}

class PokerApp extends StatelessWidget {
  const PokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
      routes: {
        '/host': (_) => HostGamePage(),
        '/join': (_) => JoinGamePage(),
        '/during_host': (_) => DuringGamePage(
          game: _createSampleGame(),
          currentPlayer: const PlayerModel(
            id: 'host_player',
            name: 'Host Player',
            inFor: 100,
            isHost: true,
            isOnline: true,
            hasPaid: true,
          ),
        ),
        '/during_player': (_) => DuringGamePage(
          game: _createSampleGame(),
          currentPlayer: const PlayerModel(
            id: 'regular_player',
            name: 'Regular Player',
            inFor: 100,
            isHost: false,
            isOnline: true,
            hasPaid: true,
          ),
        ),
        '/end_host': (_) => EndGameHostPage(),
        
        '/end_player': (_) => EndGamePage(
          player: const PlayerModel(
            id: 'test_player',
            name: 'John Doe',
            inFor: 100,
            isHost: false,
            isOnline: true,
            hasPaid: true,
          ),
          hostVenmoUsername: 'renaaron',
          initialBuyIn: 100, // Initial buy-in from game data
        ),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  final List<Map<String, String>> pages = [
    {'label': 'Host Game', 'route': '/host'},
    {'label': 'Join Game', 'route': '/join'},
    {'label': 'During Game - Host', 'route': '/during_host'},
    {'label': 'During Game - Player', 'route': '/during_player'},
    {'label': 'End Game - Host', 'route': '/end_host'},
    {'label': 'End Game - Player', 'route': '/end_player'},

  ];

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Page')),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: pages.map((page) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, page['route']!),
                child: Text(page['label']!),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

GameModel _createSampleGame() {
  return GameModel(
    id: 'ABC1234',
    hostId: 'host_player',
    hostName: 'Host Player',
    players: [
      const PlayerModel(
        id: 'host_player',
        name: 'Host Player',
        inFor: 100,
        isHost: true,
        isOnline: true,
        hasPaid: true,
      ),
      const PlayerModel(
        id: 'player1',
        name: 'Alice Johnson',
        inFor: 100,
        isHost: false,
        isOnline: true,
        hasPaid: true,
      ),
      const PlayerModel(
        id: 'player2',
        name: 'Bob Smith',
        inFor: 150,
        isHost: false,
        isOnline: true,
        hasPaid: false,
      ),
      const PlayerModel(
        id: 'player3',
        name: 'Carol Davis',
        inFor: 100,
        isHost: false,
        isOnline: false,
        hasPaid: true,
      ),
    ],
    status: GameStatus.playing,
    type: GameType.cash,
    maxPlayers: 8,
    currentPlayers: 4,
    buyIn: 100,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    startedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    venmoUsername: 'renaaron',
  );
}

class EndGameHostPage extends StatelessWidget {
  const EndGameHostPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("End Game - Host")));
}




