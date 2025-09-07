import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  // Firestore collections
  CollectionReference get games => _firestore.collection('Games');

  // Generic CRUD operations
  Future<DocumentReference> addDocument(
    CollectionReference collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await collection.add(data);
      _logger.i('Document added with ID: ${docRef.id}');
      return docRef;
    } catch (e) {
      _logger.e('Error adding document: $e');
      rethrow;
    }
  }

  Future<void> updateDocument(
    DocumentReference docRef,
    Map<String, dynamic> data,
  ) async {
    try {
      await docRef.update(data);
      _logger.i('Document updated: ${docRef.id}');
    } catch (e) {
      _logger.e('Error updating document: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(DocumentReference docRef) async {
    try {
      await docRef.delete();
      _logger.i('Document deleted: ${docRef.id}');
    } catch (e) {
      _logger.e('Error deleting document: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> getDocument(DocumentReference docRef) async {
    try {
      final snapshot = await docRef.get();
      _logger.i('Document retrieved: ${docRef.id}');
      return snapshot;
    } catch (e) {
      _logger.e('Error getting document: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCollectionStream(
    CollectionReference collection, {
    List<Query<Object?>> Function(Query<Object?> query)? queryBuilder,
  }) {
    Query query = collection;
    if (queryBuilder != null) {
      query = queryBuilder(query).first;
    }
    return query.snapshots();
  }

  // Real-time document stream
  Stream<DocumentSnapshot> getDocumentStream(DocumentReference docRef) {
    return docRef.snapshots();
  }

  // Batch operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = _firestore.batch();
    
    for (final operation in operations) {
      final type = operation['type'] as String;
      final collection = operation['collection'] as CollectionReference;
      final data = operation['data'] as Map<String, dynamic>;
      
      switch (type) {
        case 'add':
          batch.set(collection.doc(), data);
          break;
        case 'update':
          final docId = operation['docId'] as String;
          batch.update(collection.doc(docId), data);
          break;
        case 'delete':
          final docId = operation['docId'] as String;
          batch.delete(collection.doc(docId));
          break;
      }
    }
    
    await batch.commit();
    _logger.i('Batch write completed');
  }
}