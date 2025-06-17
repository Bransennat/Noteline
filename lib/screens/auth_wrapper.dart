import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesecure/screens/auth/login_screen.dart';
import 'package:notesecure/screens/notes/home_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Meminta data 'User?' dari StreamProvider yang di pasang di main.dart
    final user = Provider.of<User?>(context);

    // Cek jika data user ada (artinya sudah login)
    if (user != null) {
      // Jika sudah login, tampilkan HomeScreen
      return const HomeScreen();
    } else {
      // Jika belum login, tampilkan LoginScreen
      return const LoginScreen();
    }
  }
}