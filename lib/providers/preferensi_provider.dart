import 'package:flutter/material.dart';

enum FrekuensiPengingat { harian, bulanan }

class PreferensiProvider extends ChangeNotifier {
  String _nama = 'User JD Team';
  String _email = 'mahasiswa@example.com';
  String _programStudi = 'Ilmu Komputer';
  String _institusi = 'Universitas Sumatera Utara';

  bool _pengingatAktif = true;
  FrekuensiPengingat _frekuensi = FrekuensiPengingat.harian;
  TimeOfDay _jam = const TimeOfDay(hour: 20, minute: 0);

  String get nama => _nama;
  String get email => _email;
  String get programStudi => _programStudi;
  String get institusi => _institusi;

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
    required String programStudi,
    required String institusi,
  }) {
    _nama = nama.trim();
    _email = email.trim();
    _programStudi = programStudi.trim();
    _institusi = institusi.trim();
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