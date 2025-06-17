import 'package:flutter/foundation.dart';
import 'package:notesecure/services/firestore_service.dart';

class NoteProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters agar UI bisa mengakses state ini
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // fungsi untuk ubah state dan memberitahu UI
  void _setState({required bool loading, String? error}) {
    _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  // fungsi create yang akan dipanggil oleh UI
  Future<bool> addNote({
    required String userId,
    required String title,
    required String content,
  }) async {
    _setState(loading: true, error: null);
    final error = await _firestoreService.addNote(
      userId: userId,
      title: title,
      content: content,
    );
    _setState(loading: false, error: error);
    return error == null; 
  }

  // Fungsi update yang akan dipanggil oleh UI
  Future<bool> updateNote({
    required String userId,
    required String noteId,
    required String title,
    required String content,
  }) async {
    _setState(loading: true, error: null);
    final error = await _firestoreService.updateNote(
      userId: userId,
      noteId: noteId,
      title: title,
      content: content,
    );
    _setState(loading: false, error: error);
    return error == null;
  }

  // Fungsi delete yang akan dipanggil oleh UI
  Future<bool> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    _setState(loading: true, error: null);
    final error = await _firestoreService.deleteNote(
      userId: userId,
      noteId: noteId,
    );
    _setState(loading: false, error: error);
    return error == null;
  }
}