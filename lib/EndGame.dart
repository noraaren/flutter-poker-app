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

void removeGame() async {
  DocumentSnapshot? gameDoc = await findGame(testString);

  if (gameDoc != null) {
    DocumentReference docRef = gameDoc.reference;
    await docRef.delete();
    print("Game removed successfully.");
  } else {
    print("No game found with that code.");
  }
}