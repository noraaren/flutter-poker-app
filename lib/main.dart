import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

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

class HostGamePage extends StatelessWidget {
  const HostGamePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Host Game Page")));
}

class JoinGamePage extends StatelessWidget {
  const JoinGamePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Join Game Page")));
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

class EndGamePlayerPage extends StatefulWidget {
  const EndGamePlayerPage({super.key});

  @override
  State<EndGamePlayerPage> createState() => _EndGamePlayerPageState();
}

class _EndGamePlayerPageState extends State<EndGamePlayerPage> {
  Future<void> payWithVenmo({
    required String venmoUsername,
    required double amount,
    required String note,
  }) async {
    // Try the Venmo app first
    final venmoUrl = Uri.parse(
      'venmo://paycharge?txn=pay'
      '&recipients=$venmoUsername'
      '&amount=${amount.toStringAsFixed(2)}'
      '&note=${Uri.encodeComponent(note)}'
    );

    // Fallback to web URL
    final webUrl = Uri.parse(
      'https://venmo.com/$venmoUsername?txn=pay'
      '&amount=${amount.toStringAsFixed(2)}'
      '&note=${Uri.encodeComponent(note)}'
    );

    try {
      if (await canLaunchUrl(venmoUrl)) {
        await launchUrl(venmoUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        // Show a snackbar to inform the user
        if (mounted) {  // Check if widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch Venmo. Please install Venmo or visit venmo.com'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {  // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching Venmo: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Column(
    children: [
      Text("End Game - Player"),
      ElevatedButton(
        onPressed: () {
          payWithVenmo(
            venmoUsername: "renaaron", // e.g. "johndoe"
            amount: 10.0,
            note: "Thanks for lunch!",
          );
        },
        child: Text("Pay with Venmo"),
      )
    ],
  )));
}
