import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
        '/during_host': (_) => DuringGameHostPage(),
        '/during_player': (_) => DuringGamePlayerPage(),
        '/end_host': (_) => EndGameHostPage(),
        '/end_player': (_) => EndGamePlayerPage(),
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

class DuringGameHostPage extends StatelessWidget {
  const DuringGameHostPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("During Game - Host")));
}

class DuringGamePlayerPage extends StatelessWidget {
  const DuringGamePlayerPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("During Game - Player")));
}

class EndGameHostPage extends StatelessWidget {
  const EndGameHostPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("End Game - Host")));
}

class EndGamePlayerPage extends StatelessWidget {
  const EndGamePlayerPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("End Game - Player")));
}
