import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesecure/models/note_model.dart';
import 'package:notesecure/providers/note_provider.dart';
// Impor untuk halaman-halaman
import 'package:notesecure/screens/notes/add_note_screen.dart';
import 'package:notesecure/screens/notes/edit_note_screen.dart';
import 'package:notesecure/screens/admin/admin_user_list_screen.dart'; // Impor untuk halaman admin
// Impor untuk service dan provider
import 'package:notesecure/services/auth_service.dart';
import 'package:notesecure/services/firestore_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Sesi tidak ditemukan. Silakan login kembali."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan ${user.displayName ?? user.email}'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
        
          FutureBuilder<bool>(
            future: authService.isAdmin(), // Panggil fungsi cek admin
            builder: (context, snapshot) {
              // Jika data sudah diterima dan hasilnya true (adalah admin)
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data == true) {
                return IconButton(
                  tooltip: 'Panel Admin',
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () {
                    // Navigasi ke halaman panel admin
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminUserListScreen()),
                    );
                  },
                );
              }
              // Jika bukan admin atau masih loading, jangan tampilkan apa-apa
              return const SizedBox.shrink();
            },
          ),
          

          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          )
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: firestoreService.getNotesStream(userId: user.uid),
        builder: (context, snapshot) {
          // ... (sisa dari builder Anda tetap sama)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum memiliki catatan.\nTekan tombol + untuk membuat.',
                textAlign: TextAlign.center,
              ),
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
                  context.read<NoteProvider>().deleteNote(
                        userId: user.uid,
                        noteId: note.id,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${note.title}" telah dihapus')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditNoteScreen(note: note, userId: user.uid),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddNoteScreen(userId: user.uid)),
          );
        },
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add),
      ),
    );
  }
}