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

        // Mengirim email verifikasi ke pengguna
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

        // Beri pesan agar pengguna mengecek email
        return "Registrasi berhasil! Silakan cek email Anda untuk verifikasi.";
      }
    } on FirebaseAuthException catch (e) {
      // Menangani error spesifik dari Firebase Auth
      if (e.code == 'weak-password') {
        return 'Password yang dimasukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Akun sudah ada untuk email tersebut.';
      } else if (e.code == 'invalid-email') {
        return 'Format email tidak valid.';
      }
      return e.message ?? "Terjadi error saat registrasi.";
    } catch (e) {
      // Menangani error umum lainnya
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
      //  Coba login dengan email dan password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cek apakah email sudah diverifikasi
      User? currentUser = _auth.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        // Jika belum diverifikasi, kirim pesan spesifik
        // dan langsung logout lagi agar tidak tersangkut
        await _auth.signOut();
        return "Email belum diverifikasi. Silakan cek email Anda.";
      }

      // Jika login berhasil DAN email sudah terverifikasi
      return "Login Berhasil";

    } on FirebaseAuthException catch (e) {
      // Menangani error spesifik dari Firebase
      // Kode 'invalid-credential' biasanya untuk email tidak ditemukan atau password salah
      if (e.code == 'invalid-credential') {
        return "Email atau password yang Anda masukkan salah.";
      } else if (e.code == 'invalid-email') {
        return "Format email tidak valid.";
      }
      return e.message ?? "Terjadi error saat login.";
    } catch (e) {
      // Menangani error umum
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  //==================================================================
  // FUNGSI LOGOUT PENGGUNA
  //==================================================================
  Future<void> signOut() async {
    await _auth.signOut();
  }
}