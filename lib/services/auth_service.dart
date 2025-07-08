import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instance dari Firebase Auth & Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //==================================================================
  // STREAM UNTUK MEMANTAU STATUS LOGIN
  //==================================================================
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //==================================================================
  // FUNGSI REGISTRASI PENGGUNA BARU
  //==================================================================
  Future<String> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Buat pengguna di Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Pastikan user berhasil dibuat
      if (user != null) {
        await user.updateDisplayName(username);
        await user.sendEmailVerification();

        // Simpan data pengguna tambahan di Cloud Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username,
          'email': email,
          'createdAt': Timestamp.now(),
        });

        // Logout otomatis agar user tidak langsung masuk
        await _auth.signOut();

        return "Registrasi berhasil! Silakan cek email Anda untuk verifikasi.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password yang dimasukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Akun sudah ada untuk email tersebut.';
      } else if (e.code == 'invalid-email') {
        return 'Format email tidak valid.';
      }
      return e.message ?? "Terjadi error saat registrasi.";
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
    return 'Terjadi kesalahan yang tidak diketahui.';
  }

  //==================================================================
  // FUNGSI LOGIN PENGGUNA
  //==================================================================
  Future<String> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? currentUser = _auth.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        await _auth.signOut();
        return "Email belum diverifikasi. Silakan cek email Anda.";
      }
      return "Login Berhasil";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return "Email atau password yang Anda masukkan salah.";
      } else if (e.code == 'invalid-email') {
        return "Format email tidak valid.";
      }
      return e.message ?? "Terjadi error saat login.";
    } catch (e) {
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  //==================================================================
  // FUNGSI LOGOUT PENGGUNA
  //==================================================================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //==================================================================
  // FUNGSI UNTUK MENGECEK PERAN ADMIN (BARU)
  //==================================================================
  Future<bool> isAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        // Jika tidak ada user yang login, sudah pasti bukan admin
        return false;
      }
      // Ambil dokumen user dari Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

      // Cek apakah dokumen ada dan field 'role' bernilai 'admin'
      if (doc.exists && (doc.data() as Map<String, dynamic>)['role'] == 'admin') {
        return true;
      }

      // Jika tidak, maka bukan admin
      return false;
    } catch (e) {
      // Jika terjadi error, anggap bukan admin demi keamanan
      print(e); // Cetak error untuk debugging
      return false;
    }
  }
}