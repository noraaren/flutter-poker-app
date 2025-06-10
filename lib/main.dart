import 'package:flutter/material.dart';

void main() => runApp(PokerApp());

class PokerApp extends StatelessWidget {
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

class HostGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Host Game Page")));
}

class JoinGamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Join Game Page")));
}

class DuringGameHostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("During Game - Host")));
}

class DuringGamePlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("During Game - Player")));
}

class EndGameHostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("End Game - Host")));
}

class EndGamePlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("End Game - Player")));
}
