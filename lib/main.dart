import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notesecure/screens/auth_wrapper.dart';
import 'package:notesecure/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:notesecure/providers/note_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider menyediakan stream status login ke seluruh aplikasi
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
        ChangeNotifierProvider(
          create: (context) => NoteProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NoteSecure',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        // Halaman utama adalah AuthWrapper
        home: const AuthWrapper(),
      ),
    );
  }
}