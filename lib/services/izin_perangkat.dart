import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HasilIzin { diberikan, dibatalkan, ditolak, ditolakPermanen }

class IzinPerangkat {
  IzinPerangkat._();

  static const _kunciKamera = 'penjelasan_izin_kamera';
  static const _kunciGaleri = 'izin_galeri_sudah_diminta';

  static bool get _android => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<HasilIzin> kamera(BuildContext context) async {
    if (!_android) return HasilIzin.diberikan;
    var status = await Permission.camera.status;
    if (status.isGranted) return HasilIzin.diberikan;
    if (status.isPermanentlyDenied) return HasilIzin.ditolakPermanen;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_kunciKamera) ?? false)) {
      if (!context.mounted) return HasilIzin.dibatalkan;
      final lanjut = await _tampilkanPenjelasan(
        context,
        ikon: Icons.camera_alt_rounded,
        judul: 'Izinkan akses kamera',
        isi: 'BonKu memakai kamera untuk memotret struk dan foto profil. '
            'Foto hanya diambil saat kamu menekan tombol ambil foto.',
      );
      if (!lanjut) return HasilIzin.dibatalkan;
      await prefs.setBool(_kunciKamera, true);
    }
    status = await Permission.camera.request();
    if (status.isGranted) return HasilIzin.diberikan;
    return status.isPermanentlyDenied ? HasilIzin.ditolakPermanen : HasilIzin.ditolak;
  }

  static Future<HasilIzin> galeri(BuildContext context) async {
    if (!_android) return HasilIzin.diberikan;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kunciGaleri) ?? false) return HasilIzin.diberikan;
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      await prefs.setBool(_kunciGaleri, true);
      return HasilIzin.diberikan;
    }
    if (!context.mounted) return HasilIzin.dibatalkan;
    final lanjut = await _tampilkanPenjelasan(
      context,
      ikon: Icons.photo_library_rounded,
      judul: 'Izinkan akses galeri',
      isi: 'BonKu membuka galeri agar kamu bisa memilih gambar struk atau foto profil. '
          'Hanya gambar yang kamu pilih yang dipakai.',
    );
    if (!lanjut) return HasilIzin.dibatalkan;
    await Permission.photos.request();
    await prefs.setBool(_kunciGaleri, true);
    return HasilIzin.diberikan;
  }

  static Future<bool> _tampilkanPenjelasan(
      BuildContext context, {
        required IconData ikon,
        required String judul,
        required String isi,
      }) async {
    final lanjut = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(ikon),
        title: Text(judul),
        content: Text(isi),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Nanti'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
    return lanjut == true;
  }
}