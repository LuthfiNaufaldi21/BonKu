import 'dart:math' as math;

import '../models/item_transaksi.dart';
import '../models/kategori.dart';
import '../models/transaksi.dart';

/// Data simulasi awal: 6 kategori (referensi), 24 transaksi contoh (Agu-Sep 2026),
/// dan transaksi dummy otomatis untuk 12 bulan terakhir sampai bulan ini.
class SeedData {
  static const katKonsumsi = 'kat-konsumsi';
  static const katTransportasi = 'kat-transportasi';
  static const katEdukasi = 'kat-edukasi';
  static const katKesehatan = 'kat-kesehatan';
  static const katHiburan = 'kat-hiburan';
  static const katLain = 'kat-lain'; // "Lain-lain / Belum Dikategorikan" (FR-03)

  static List<Kategori> kategori() => const [
        Kategori(id: katKonsumsi, nama: 'Konsumsi', warna: 0xFFEF6C00),
        Kategori(id: katTransportasi, nama: 'Transportasi', warna: 0xFF1E88E5),
        Kategori(id: katEdukasi, nama: 'Edukasi', warna: 0xFF8E24AA),
        Kategori(id: katKesehatan, nama: 'Kesehatan', warna: 0xFFE53935),
        Kategori(id: katHiburan, nama: 'Hiburan', warna: 0xFF43A047),
        Kategori(
            id: katLain,
            nama: 'Lain-lain / Belum Dikategorikan',
            warna: 0xFF757575),
      ];

  static Transaksi _trx(
    int no,
    String toko,
    DateTime tanggal,
    SumberResi sumber,
    List<(String, String, int)> items, {
    String catatan = '',
  }) {
    final nomor = no.toString().padLeft(3, '0');
    final id = 'trx-$nomor';
    return Transaksi(
      id: id,
      toko: toko,
      tanggal: tanggal,
      sumber: sumber,
      catatan: catatan,
      items: [
        for (var i = 0; i < items.length; i++)
          ItemTransaksi(
            id: 'itm-$nomor-${i + 1}',
            transaksiId: id,
            nama: items[i].$1,
            kategoriId: items[i].$2,
            harga: items[i].$3,
          ),
      ],
    );
  }

  static List<Transaksi> _contohManual() => [
        // ---- September 2026 ----
        _trx(1, 'Indomaret Setia Budi', DateTime(2026, 9, 30, 19, 30),
            SumberResi.kamera, [
          ('Air Mineral 600ml', katKonsumsi, 4000),
          ('Roti Sobek', katKonsumsi, 12500),
          ('Tisu Wajah', katLain, 9000),
        ]),
        _trx(2, 'GoPay - Gojek', DateTime(2026, 9, 29, 8, 10),
            SumberResi.share, [
          ('Perjalanan Gojek', katTransportasi, 18000),
        ]),
        _trx(3, 'Gramedia Medan', DateTime(2026, 9, 27, 16, 45),
            SumberResi.kamera, [
          ('Buku Tulis', katEdukasi, 15000),
          ('Pulpen Gel', katEdukasi, 12000),
          ('Penggaris', katEdukasi, 6000),
        ]),
        _trx(4, 'Warung Nasi Bu Ani', DateTime(2026, 9, 26, 12, 20),
            SumberResi.manual, [
          ('Nasi Goreng Spesial', katKonsumsi, 25000),
          ('Es Teh Manis', katKonsumsi, 5000),
        ]),
        _trx(5, 'Apotek K-24', DateTime(2026, 9, 24, 18, 5), SumberResi.kamera, [
          ('Vitamin C', katKesehatan, 35000),
          ('Masker', katKesehatan, 15000),
        ]),
        _trx(6, 'Bioskop XXI', DateTime(2026, 9, 22, 19, 0), SumberResi.share, [
          ('Tiket Film', katHiburan, 50000),
          ('Popcorn', katHiburan, 35000),
        ]),
        _trx(7, 'Alfamart', DateTime(2026, 9, 20, 10, 15), SumberResi.kamera, [
          ('Mie Instan 5 bungkus', katKonsumsi, 17500),
          ('Telur 1/2 kg', katKonsumsi, 16000),
          ('Sabun Cuci Piring', katLain, 14000),
        ]),
        _trx(8, 'Grab', DateTime(2026, 9, 18, 7, 45), SumberResi.share, [
          ('Perjalanan Grab', katTransportasi, 22000),
        ]),
        _trx(9, 'Kopi Kenangan', DateTime(2026, 9, 16, 15, 30), SumberResi.share, [
          ('Kopi Susu', katKonsumsi, 24000),
        ]),
        _trx(10, 'Tokopedia - Aksesoris', DateTime(2026, 9, 14, 20, 0),
            SumberResi.share, [
          ('Flashdisk 32GB', katEdukasi, 65000),
          ('Kabel USB', katLain, 25000),
        ]),
        _trx(11, 'Pertamina SPBU', DateTime(2026, 9, 12, 9, 0),
            SumberResi.kamera, [
          ('Pertalite', katTransportasi, 50000),
        ]),
        _trx(12, 'Klinik Pratama USU', DateTime(2026, 9, 10, 11, 40),
            SumberResi.kamera, [
          ('Konsultasi Dokter', katKesehatan, 30000),
          ('Obat Flu', katKesehatan, 12000),
        ]),
        _trx(13, 'Steam Wallet', DateTime(2026, 9, 8, 21, 10), SumberResi.share, [
          ('Game', katHiburan, 75000),
        ]),
        _trx(14, 'Superindo', DateTime(2026, 9, 6, 17, 25), SumberResi.kamera, [
          ('Beras 5kg', katKonsumsi, 68000),
          ('Minyak Goreng', katKonsumsi, 32000),
          ('Sabun Mandi', katLain, 8500),
          ('Susu UHT', katKonsumsi, 18000),
        ]),
        _trx(15, 'Fotokopi Kampus', DateTime(2026, 9, 4, 13, 0), SumberResi.manual, [
          ('Print Makalah', katEdukasi, 8000),
          ('Jilid', katEdukasi, 5000),
        ]),
        _trx(16, 'Gojek - GoFood', DateTime(2026, 9, 2, 12, 50), SumberResi.share, [
          ('Ayam Geprek', katKonsumsi, 28000),
          ('Ongkos Kirim', katTransportasi, 8000),
        ]),
        // ---- Agustus 2026 ----
        _trx(17, 'Alfamart', DateTime(2026, 8, 29, 18, 20), SumberResi.kamera, [
          ('Air Mineral 1.5L', katKonsumsi, 6000),
          ('Snack Kentang', katKonsumsi, 11000),
          ('Tisu Wajah', katLain, 9000),
        ]),
        _trx(18, 'Gramedia Medan', DateTime(2026, 8, 25, 16, 0), SumberResi.kamera, [
          ('Novel', katHiburan, 89000),
        ]),
        _trx(19, 'Grab', DateTime(2026, 8, 22, 8, 30), SumberResi.share, [
          ('Perjalanan Grab', katTransportasi, 19000),
        ]),
        _trx(20, 'Apotek Kimia Farma', DateTime(2026, 8, 18, 17, 45),
            SumberResi.kamera, [
          ('Paracetamol', katKesehatan, 8000),
          ('Plester', katKesehatan, 6000),
        ]),
        _trx(21, 'Warung Mie Aceh', DateTime(2026, 8, 15, 13, 10),
            SumberResi.manual, [
          ('Mie Aceh', katKonsumsi, 28000),
          ('Teh Tarik', katKonsumsi, 8000),
        ]),
        _trx(22, 'Netflix', DateTime(2026, 8, 10, 6, 0), SumberResi.share, [
          ('Langganan Bulanan', katHiburan, 54000),
        ]),
        _trx(23, 'Indomaret', DateTime(2026, 8, 5, 19, 15), SumberResi.kamera, [
          ('Roti Tawar', katKonsumsi, 15000),
          ('Selai Cokelat', katKonsumsi, 18500),
        ]),
        _trx(24, 'Parkir Kampus', DateTime(2026, 8, 3, 7, 30), SumberResi.manual, [
          ('Parkir Bulanan', katTransportasi, 30000),
        ]),
      ];

  /// Contoh manual + dummy bulanan (bulan yang sudah punya contoh dilewati).
  static List<Transaksi> transaksi() => [..._contohManual(), ..._dummyBulanan()];

  // Pola belanja yang diulang dengan harga dan tanggal acak (tetap sama tiap dijalankan).
  static final List<(String, SumberResi, List<(String, String, int)>)> _pola = [
    ('Indomaret', SumberResi.kamera, [('Air Mineral', katKonsumsi, 4000), ('Roti Sobek', katKonsumsi, 12500), ('Tisu Wajah', katLain, 9000)]),
    ('Gojek', SumberResi.share, [('Perjalanan Gojek', katTransportasi, 18000)]),
    ('Gramedia Medan', SumberResi.kamera, [('Buku Tulis', katEdukasi, 15000), ('Pulpen Gel', katEdukasi, 12000)]),
    ('Warung Nasi Bu Ani', SumberResi.manual, [('Nasi Goreng Spesial', katKonsumsi, 25000), ('Es Teh Manis', katKonsumsi, 5000)]),
    ('Apotek K-24', SumberResi.kamera, [('Vitamin C', katKesehatan, 35000), ('Masker', katKesehatan, 15000)]),
    ('Bioskop XXI', SumberResi.share, [('Tiket Film', katHiburan, 50000), ('Popcorn', katHiburan, 35000)]),
    ('Alfamart', SumberResi.kamera, [('Mie Instan', katKonsumsi, 17500), ('Telur 1/2 kg', katKonsumsi, 16000), ('Sabun Cuci', katLain, 14000)]),
    ('Grab', SumberResi.share, [('Perjalanan Grab', katTransportasi, 22000)]),
    ('Kopi Kenangan', SumberResi.share, [('Kopi Susu', katKonsumsi, 24000)]),
    ('Tokopedia', SumberResi.share, [('Flashdisk 32GB', katEdukasi, 65000), ('Kabel USB', katLain, 25000)]),
    ('Pertamina SPBU', SumberResi.kamera, [('Pertalite', katTransportasi, 50000)]),
    ('Klinik Pratama USU', SumberResi.kamera, [('Konsultasi Dokter', katKesehatan, 30000), ('Obat Flu', katKesehatan, 12000)]),
    ('Steam Wallet', SumberResi.share, [('Game', katHiburan, 75000)]),
    ('Superindo', SumberResi.kamera, [('Beras 5kg', katKonsumsi, 68000), ('Minyak Goreng', katKonsumsi, 32000), ('Susu UHT', katKonsumsi, 18000)]),
    ('Fotokopi Kampus', SumberResi.manual, [('Print Makalah', katEdukasi, 8000), ('Jilid', katEdukasi, 5000)]),
    ('GoFood', SumberResi.share, [('Ayam Geprek', katKonsumsi, 28000), ('Ongkos Kirim', katTransportasi, 8000)]),
    ('Netflix', SumberResi.share, [('Langganan Bulanan', katHiburan, 54000)]),
    ('Parkir Kampus', SumberResi.manual, [('Parkir Bulanan', katTransportasi, 30000)]),
  ];

  /// Transaksi dummy untuk 12 bulan terakhir sampai bulan ini. Bulan yang sudah
  /// punya data contoh dilewati, dan tanggal tidak pernah melewati hari ini.
  static List<Transaksi> _dummyBulanan() {
    final sekarang = DateTime.now();
    final sudahAda = {
      for (final t in _contohManual()) t.tanggal.year * 100 + t.tanggal.month,
    };

    final hasil = <Transaksi>[];
    var no = 100;
    for (var mundur = 11; mundur >= 0; mundur--) {
      final bulan = DateTime(sekarang.year, sekarang.month - mundur);
      final kunci = bulan.year * 100 + bulan.month;
      if (sudahAda.contains(kunci)) continue;

      final acak = math.Random(kunci); // tetap sama untuk bulan yang sama
      final faktorBulan = 0.7 + acak.nextDouble() * 0.9; // tren naik-turun antar bulan
      final jumlah = 6 + acak.nextInt(5); // 6-10 transaksi per bulan
      final sebulanPenuh = DateTime(bulan.year, bulan.month + 1, 0).day;
      final hariMaks = (bulan.year == sekarang.year && bulan.month == sekarang.month)
          ? sekarang.day
          : sebulanPenuh;

      for (var i = 0; i < jumlah; i++) {
        final pola = _pola[acak.nextInt(_pola.length)];
        final hari = 1 + acak.nextInt(hariMaks);
        var jam = 7 + acak.nextInt(15);
        var menit = acak.nextInt(60);
        final hariIni = bulan.year == sekarang.year &&
            bulan.month == sekarang.month &&
            hari == sekarang.day;
        if (hariIni && (jam > sekarang.hour || (jam == sekarang.hour && menit > sekarang.minute))) {
          jam = sekarang.hour;
          menit = 0;
        }

        final items = [
          for (final it in pola.$3)
            (
              it.$1,
              it.$2,
              math.max(1000, ((it.$3 * faktorBulan * (0.85 + acak.nextDouble() * 0.3)) / 500).round() * 500),
            ),
        ];
        hasil.add(_trx(no++, pola.$1, DateTime(bulan.year, bulan.month, hari, jam, menit), pola.$2, items));
      }
    }
    return hasil;
  }
}