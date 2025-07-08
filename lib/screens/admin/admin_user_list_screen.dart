import 'package:flutter/material.dart';
import 'package:notesecure/services/firestore_service.dart';
import 'package:notesecure/screens/admin/admin_note_list_screen.dart'; // Impor untuk langkah selanjutnya

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mendapatkan semua user saat halaman pertama kali dibuka
    _usersFuture = _firestoreService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin - Daftar Pengguna'),
        backgroundColor: Colors.indigo, // Warna beda untuk panel admin
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture, // Gunakan future yang sudah kita panggil
        builder: (context, snapshot) {
          // Tampilkan loading indicator selagi menunggu data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Tampilkan pesan jika ada error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Tampilkan pesan jika tidak ada data sama sekali
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada pengguna yang terdaftar.'));
          }

          // Jika data berhasil didapat, tampilkan list
          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              // Ambil data username dan email, beri nilai default jika null
              final String username = user['username'] ?? 'Tanpa Username';
              final String email = user['email'] ?? 'Tanpa Email';
              final String userId = user['uid'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(username),
                  subtitle: Text(email),
                  onTap: () {
                    // Navigasi ke halaman detail catatan milik user ini
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminNoteListScreen(
                          selectedUserId: userId,
                          selectedUsername: username,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}