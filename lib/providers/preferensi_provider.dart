import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FrekuensiPengingat { harian, bulanan }

class PreferensiProvider extends ChangeNotifier {
  PreferensiProvider() {
    _muatModeDemo();
  }

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
  String _telepon = '081234567890';
  String _bio = 'Pencatat Keuangan Handal';
  String? _fotoProfil; 

  bool _pengingatAktif = true;
  FrekuensiPengingat _frekuensi = FrekuensiPengingat.harian;
  TimeOfDay _jam = const TimeOfDay(hour: 20, minute: 0);

  String get nama => _nama;
  String get email => _email;
  String get telepon => _telepon;
  String get bio => _bio;
  String? get fotoProfil => _fotoProfil;

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
    notifyListeners();
  }

  void ubahProfil({
    required String nama,
    required String email,
    required String telepon,
    required String bio,
    String? fotoProfil,
  }) {
    _nama = nama.trim();
    _email = email.trim();
    _telepon = telepon.trim();
    _bio = bio.trim();
    if (fotoProfil != null) _fotoProfil = fotoProfil;
    notifyListeners();
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