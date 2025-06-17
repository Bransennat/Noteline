import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesecure/models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //==================================================================
  // FUNGSI UNTUK MENAMBAHKAN CATATAN BARU (CREATE)
  //==================================================================
  Future<String?> addNote({
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      CollectionReference userNotesCollection =
          _firestore.collection('users').doc(userId).collection('notes');

      DocumentReference newNoteDoc = userNotesCollection.doc();
      String noteId = newNoteDoc.id;

      Note newNote = Note(
        id: noteId,
        title: title,
        content: content,
        createdAt: Timestamp.now(),
      );

      await newNoteDoc.set(newNote.toJson());

      return null;
    } catch (e) {
      return "Gagal menambahkan catatan: ${e.toString()}";
    }
  }

  //==================================================================
  // FUNGSI UNTUK MENGAMBIL STREAM CATATAN (READ)
  //==================================================================
  Stream<List<Note>> getNotesStream({required String userId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  //==================================================================
  // FUNGSI UNTUK MEMPERBARUI CATATAN (UPDATE)
  //==================================================================
  Future<String?> updateNote({
    required String userId,
    required String noteId,
    required String title,
    required String content,
  }) async {
    try {
      DocumentReference noteDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId);

      await noteDoc.update({
        'title': title,
        'content': content,
      });

      return null;
    } catch (e) {
      return "Gagal memperbarui catatan: ${e.toString()}";
    }
  }

  //==================================================================
  // FUNGSI UNTUK MENGHAPUS CATATAN (DELETE)
  //==================================================================
  Future<String?> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    try {
      DocumentReference noteDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId);

      await noteDoc.delete();

      return null;
    } catch (e) {
      return "Gagal menghapus catatan: ${e.toString()}";
    }
  }
}