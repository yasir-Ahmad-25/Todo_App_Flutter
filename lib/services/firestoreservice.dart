import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Firestoreservice {
  // creating collection
  final _firestore = FirebaseFirestore.instance;

  // CREATE : create note
  Future<void> addNote(String note) async {
    try {
      // await _firestore.add({"note": note, 'created-time': Timestamp.now()});
      await _firestore
          .collection("notes")
          .add({"note": note, 'created-time': Timestamp.now()});
    } catch (e) {
      if (kDebugMode) {
        print("Error occured: $e");
      }
    }
  }

  // READ : get all Notes
  Stream<QuerySnapshot>? getNotes() {
    final noteStream = _firestore
        .collection("notes")
        .orderBy('created-time', descending: true)
        .snapshots();
    return noteStream;
  }

  // UPDATE : update specified note
  Future<void> updateNote(String docID, String newNote) async {
    try {
      await _firestore
          .collection("notes")
          .doc(docID)
          .update({'note': newNote, 'created-time': Timestamp.now()});
    } catch (e) {
      if (kDebugMode) {
        print("Error Reading Data : $e");
      }
    }
  }

  // DELETE :  delete selected note
  Future<void> deleteNote(String docID) async {
    try {
      await _firestore.collection("notes").doc(docID).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
