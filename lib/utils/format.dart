import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/transaksi.dart';

class Format {
  static const _bulanPanjang = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _bulanPendek = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String rupiah(int nilai) {
    final s = nilai.abs().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '${nilai < 0 ? '-' : ''}Rp $b';
  }

  static String _dua(int n) => n.toString().padLeft(2, '0');

  static String jam(DateTime d) => '${_dua(d.hour)}:${_dua(d.minute)}';

  static String tanggalJam(DateTime d) {
    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final hariD = DateTime(d.year, d.month, d.day);
    final selisih = hariIni.difference(hariD).inDays;
    if (selisih == 0) return 'Hari ini, ${jam(d)}';
    if (selisih == 1) return 'Kemarin, ${jam(d)}';
    return '${d.day} ${_bulanPendek[d.month - 1]}, ${jam(d)}';
  }

  static String tanggalPanjang(DateTime d) =>
      '${d.day} ${_bulanPanjang[d.month - 1]} ${d.year}';

  static String bulanTahun(DateTime d) =>
      '${_bulanPanjang[d.month - 1]} ${d.year}';

  static String labelSumber(SumberResi s) => switch (s) {
        SumberResi.kamera => 'Kamera',
        SumberResi.share => 'Share',
        SumberResi.manual => 'Manual',
      };

  static IconData ikonSumber(SumberResi s) => switch (s) {
        SumberResi.kamera => Icons.receipt_long_rounded,
        SumberResi.share => Icons.share_rounded,
        SumberResi.manual => Icons.edit_note_rounded,
      };

  static Color warnaSumber(SumberResi s) => switch (s) {
        SumberResi.kamera => Colors.orange,
        SumberResi.share => Colors.blue,
        SumberResi.manual => Colors.green,
      };

  static IconData ikonKategori(String kategoriId) {
    switch (kategoriId) {
      case SeedData.katKonsumsi:
        return Icons.fastfood_rounded;
      case SeedData.katTransportasi:
        return Icons.directions_car_rounded;
      case SeedData.katEdukasi:
        return Icons.menu_book_rounded;
      case SeedData.katKesehatan:
        return Icons.medical_services_rounded;
      case SeedData.katHiburan:
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}