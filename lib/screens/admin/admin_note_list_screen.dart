import 'package:flutter/material.dart';
import 'package:notesecure/models/note_model.dart';
import 'package:notesecure/providers/note_provider.dart';
import 'package:notesecure/screens/notes/add_note_screen.dart';
import 'package:notesecure/screens/notes/edit_note_screen.dart';
import 'package:notesecure/services/firestore_service.dart';
import 'package:provider/provider.dart';

class AdminNoteListScreen extends StatelessWidget {
  // Menerima data user yang dipilih dari halaman sebelumnya
  final String selectedUserId;
  final String selectedUsername;

  const AdminNoteListScreen({
    super.key,
    required this.selectedUserId,
    required this.selectedUsername,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        // Judul AppBar menampilkan nama user yang sedang dilihat
        title: Text('Catatan Milik $selectedUsername'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Note>>(
        // Mengambil stream catatan berdasarkan ID user yang dipilih
        stream: firestoreService.getNotesStream(userId: selectedUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Pengguna ini belum memiliki catatan.'),
            );
          }

          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: ValueKey(note.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Admin menghapus catatan milik user yang dipilih
                  context.read<NoteProvider>().deleteNote(
                        userId: selectedUserId,
                        noteId: note.id,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('"${note.title}" telah dihapus')),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Admin membuka halaman edit untuk catatan milik user yang dipilih
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNoteScreen(
                            note: note,
                            userId: selectedUserId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // Tombol tambah ini akan membuat catatan untuk user yang dipilih
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(userId: selectedUserId),
            ),
          );
        },
        tooltip: 'Tambah Catatan untuk User Ini',
        child: const Icon(Icons.add),
      ),
    );
  }
}