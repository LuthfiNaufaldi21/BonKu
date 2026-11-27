import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/firestore_profil_repository.dart';
import '../repositories/profil_repository.dart';

enum FrekuensiPengingat { harian, bulanan }

class PreferensiProvider extends ChangeNotifier {
  PreferensiProvider({ProfilRepository? profilRepo}) : _profilRepo = profilRepo {
    _muatModeDemo();
  }

  ProfilRepository? _profilRepo;

  /// Dibuat saat pertama dipakai, supaya tidak menyentuh Firebase sebelum perlu.
  ProfilRepository get _repo => _profilRepo ??= FirestoreProfilRepository();

  static const _kModeDemo = 'mode_demo';

  bool _modeDemo = false;
  bool get modeDemo => _modeDemo;

  Future<void> _muatModeDemo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _modeDemo = prefs.getBool(_kModeDemo) ?? false;
      notifyListeners();
    } catch (_) {
      // Gagal membaca: biarkan Mode Demo nonaktif.
    }
  }

  Future<void> setModeDemo(bool aktif) async {
    if (aktif == _modeDemo) return;
    _modeDemo = aktif;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kModeDemo, aktif);
    } catch (_) {}
  }

  String _nama = 'Lutpi D Naupaldi';
  String _email = 'lutpi@email.com';
  static const _teleponAwal = '081234567890';
  static const _bioAwal = 'Pencatat Keuangan Handal';

  String _telepon = _teleponAwal;
  String _bio = _bioAwal;
  Uint8List? _fotoBytes;

  bool _pengingatAktif = true;
  FrekuensiPengingat _frekuensi = FrekuensiPengingat.harian;
  TimeOfDay _jam = const TimeOfDay(hour: 20, minute: 0);

  String get nama => _nama;
  String get email => _email;
  String get telepon => _telepon;
  String get bio => _bio;
  Uint8List? get fotoBytes => _fotoBytes;

  bool get pengingatAktif => _pengingatAktif;
  FrekuensiPengingat get frekuensi => _frekuensi;
  TimeOfDay get jam => _jam;

  String get jamTeks =>
      '${_jam.hour.toString().padLeft(2, '0')}:${_jam.minute.toString().padLeft(2, '0')}';

  String get jadwalTeks => _frekuensi == FrekuensiPengingat.harian
      ? 'Setiap hari pukul $jamTeks'
      : 'Setiap akhir bulan pukul $jamTeks';

  void masuk({required String email, String? nama}) {
    _email = email.trim();
    if (nama != null && nama.trim().isNotEmpty) _nama = nama.trim();
    // Profil akun sebelumnya tidak boleh terbawa ke akun yang baru masuk.
    _telepon = _teleponAwal;
    _bio = _bioAwal;
    _fotoBytes = null;
    notifyListeners();
    _muatProfil();
  }

  /// Mengambil profil (termasuk foto) dari database setelah masuk.
  Future<void> _muatProfil() async {
    final emailSaatMuat = _email;
    try {
      final data = await _repo.muat();
      if (data == null || _email != emailSaatMuat) return; // belum ada, atau akun sudah berganti
      if (data.nama.isNotEmpty) _nama = data.nama;
      _telepon = data.telepon;
      _bio = data.bio;
      _fotoBytes = data.foto;
      notifyListeners();
    } catch (_) {
      // Offline atau belum ada profil: tetap memakai nilai yang ada di perangkat.
    }
  }

  Future<String?> ubahProfil({
    required String nama,
    required String email,
    required String telepon,
    required String bio,
    Uint8List? fotoBytes,
  }) async {
    _nama = nama.trim();
    _email = email.trim();
    _telepon = telepon.trim();
    _bio = bio.trim();
    if (fotoBytes != null) _fotoBytes = fotoBytes;
    notifyListeners();
    try {
      await _repo.simpan(ProfilData(nama: _nama, telepon: _telepon, bio: _bio, foto: _fotoBytes));
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  void setPengingat(bool aktif) {
    if (aktif == _pengingatAktif) return;
    _pengingatAktif = aktif;
    notifyListeners();
  }

  void setJadwal(FrekuensiPengingat frekuensi, TimeOfDay jam) {
    _frekuensi = frekuensi;
    _jam = jam;
    notifyListeners();
  }
}