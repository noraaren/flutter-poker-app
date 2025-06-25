import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

final db = FirebaseFirestore.instance;
String gameID = "";

void generateGameCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
  final rand = Random();
  gameID = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
}

void createGameDocument() {
  generateGameCode(); // make sure gameID is set before creating the user map

  Map<String, dynamic> table = {
  "GameID": gameID,
  "GameHostVenmoUserName": "renaaron",
  "users": [
  { "username": "alice", "venmo": "@alice", "buyIn": 50 },
  { "username": "bob", "venmo": "@bob", "buyIn": 50 }
  ],
  "NumberOfPlayers": 1,
  "BuyIns" : 1, 
};

  db.collection("Games").add(table).then((DocumentReference doc) {
    print('DocumentSnapshot added with ID: ${doc.id}');
  });
}




class HostGamePage extends StatelessWidget {
  const HostGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Host Game")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            createGameDocument(); // ✅ call it here
          },
          child: Text("Create Game"),
        ),
      ),
    );
  }
}


