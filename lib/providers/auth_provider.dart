import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pengguna.dart';
import '../repositories/auth_repository.dart';

/// Status masuk pengguna untuk seluruh aplikasi.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo) {
    _pengguna = _repo.penggunaSaatIni;
    _langganan = _repo.perubahanPengguna.listen((p) {
      _pengguna = p;
      notifyListeners();
    });
  }

  final AuthRepository _repo;
  late final StreamSubscription<Pengguna?> _langganan;

  Pengguna? _pengguna;
  bool _sedangProses = false;
  String? _errorMessage;

  Pengguna? get pengguna => _pengguna;
  bool get sudahMasuk => _pengguna != null;
  bool get sedangProses => _sedangProses;
  String? get errorMessage => _errorMessage;

  /// Mengembalikan true jika berhasil. Jika gagal, lihat [errorMessage].
  Future<bool> masuk({required String email, required String sandi}) =>
      _jalankan(() async {
        _pengguna = await _repo.masuk(email: email, sandi: sandi);
      });

  Future<bool> daftar({
    required String nama,
    required String email,
    required String sandi,
  }) =>
      _jalankan(() async {
        _pengguna = await _repo.daftar(nama: nama, email: email, sandi: sandi);
      });

  Future<bool> kirimResetSandi(String email) =>
      _jalankan(() => _repo.kirimResetSandi(email));

  Future<void> keluar() async {
    await _repo.keluar();
    _pengguna = null;
    notifyListeners();
  }

  Future<bool> _jalankan(Future<void> Function() aksi) async {
    if (_sedangProses) return false; // cegah klik ganda
    _sedangProses = true;
    _errorMessage = null;
    notifyListeners();
    var berhasil = false;
    try {
      await aksi();
      berhasil = true;
    } on AuthException catch (e) {
      _errorMessage = e.pesan;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan. Periksa koneksi lalu coba lagi.';
    }
    _sedangProses = false;
    notifyListeners();
    return berhasil;
  }

  @override
  void dispose() {
    _langganan.cancel();
    super.dispose();
  }
}