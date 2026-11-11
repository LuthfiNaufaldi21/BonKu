import 'package:firebase_auth/firebase_auth.dart';

import '../models/pengguna.dart';
import 'auth_repository.dart';

/// Autentikasi email dan kata sandi memakai Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Pengguna? _petakan(User? u) => u == null
      ? null
      : Pengguna(uid: u.uid, email: u.email ?? '', nama: u.displayName ?? '');

  @override
  Pengguna? get penggunaSaatIni => _petakan(_auth.currentUser);

  @override
  Stream<Pengguna?> get perubahanPengguna => _auth.userChanges().map(_petakan);

  @override
  Future<Pengguna> masuk({required String email, required String sandi}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: sandi,
      );
      return _petakan(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_pesan(e.code));
    }
  }

  @override
  Future<Pengguna> daftar({
    required String nama,
    required String email,
    required String sandi,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: sandi,
      );
      await cred.user!.updateDisplayName(nama.trim());
      await cred.user!.reload();
      return _petakan(_auth.currentUser)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_pesan(e.code));
    }
  }

  @override
  Future<void> keluar() => _auth.signOut();

  @override
  Future<void> kirimResetSandi(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_pesan(e.code));
    }
  }

  /// Menerjemahkan kode galat Firebase menjadi pesan yang mudah dipahami.
  String _pesan(String kode) {
    switch (kode) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter).';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Coba lagi.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
      case 'operation-not-allowed':
        return 'Masuk dengan email belum diaktifkan di Firebase Console.';
      default:
        return 'Terjadi kesalahan ($kode). Coba lagi.';
    }
  }
}