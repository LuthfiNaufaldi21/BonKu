import 'dart:typed_data';

class ProfilData {
  const ProfilData({
    required this.nama,
    required this.telepon,
    required this.bio,
    this.foto,
  });

  final String nama;
  final String telepon;
  final String bio;

  final Uint8List? foto;

  static const maksBytesFoto = 600 * 1024;
}

abstract class ProfilRepository {
  Future<ProfilData?> muat();

  Future<void> simpan(ProfilData data);
}