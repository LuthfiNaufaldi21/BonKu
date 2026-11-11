import '../models/pengguna.dart';

/// Galat autentikasi dengan pesan yang sudah ramah pengguna (bahasa Indonesia).
class AuthException implements Exception {
  final String pesan;

  const AuthException(this.pesan);

  @override
  String toString() => pesan;
}

/// Kontrak autentikasi. Implementasi: FirebaseAuthRepository.
abstract class AuthRepository {
  /// Pengguna yang sedang masuk, atau null jika belum masuk.
  Pengguna? get penggunaSaatIni;

  /// Mengalirkan perubahan status masuk/keluar dan perubahan profil.
  Stream<Pengguna?> get perubahanPengguna;

  Future<Pengguna> masuk({required String email, required String sandi});

  Future<Pengguna> daftar({
    required String nama,
    required String email,
    required String sandi,
  });

  Future<void> keluar();

  Future<void> kirimResetSandi(String email);
}