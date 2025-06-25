import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final CollectionReference gamesRef = db.collection('Games');
final testString = "ABCCD";

// Make it async because Firestore operations are asynchronous
Future<DocumentSnapshot?> findGame(String insertedCode) async {
  QuerySnapshot snapshot = await gamesRef
      .where('GameID', isEqualTo: insertedCode)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first;
  } else {
    return null;
  }
}


void joinGame() async {
  DocumentSnapshot? gameDoc = await findGame(testString);

  if (gameDoc != null) {
    DocumentReference docRef = gameDoc.reference;

    Map<String, dynamic> newUser = {
      "username": "charlie",
      "venmo": "@charlie",
      "buyIn": 50,
    };

    await docRef.update({
      "users": FieldValue.arrayUnion([newUser]),
      "NumberOfPlayers": FieldValue.increment(1),
      "BuyIns": FieldValue.increment(1),
    });

    print("User added successfully!");
  } else {
    print("Game not found.");
  }
}
