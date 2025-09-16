import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/game/pages/end_game_page.dart';
import 'features/game/pages/during_game_page.dart';
import 'features/game/pages/host_game_page.dart';
import 'features/game/pages/join_game_page.dart';
import 'features/game/provider/game_provider.dart';
import 'features/game/provider/player_provider.dart';
import 'core/services/firebase_service.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameProvider(FirebaseService())),
        ChangeNotifierProvider(create: (context) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'Poker App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(),
        routes: {
          '/host': (_) => HostGamePage(),
          '/join': (_) => JoinGamePage(),
          '/during_game': (_) => DuringGamePage(),
          '/end_game': (_) => EndGamePage(),
        },
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final List<Map<String, String>> pages = [
    {'label': 'Host Game', 'route': '/host'},
    {'label': 'Join Game', 'route': '/join'},
    {'label': 'During Game (Demo)', 'route': '/during_game'},
    {'label': 'End Game (Demo)', 'route': '/end_game'},
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





