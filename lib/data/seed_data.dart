import '../models/item_transaksi.dart';
import '../models/kategori.dart';
import '../models/transaksi.dart';

class SeedData {
  static const katKonsumsi = 'kat-konsumsi';
  static const katTransportasi = 'kat-transportasi';
  static const katEdukasi = 'kat-edukasi';
  static const katKesehatan = 'kat-kesehatan';
  static const katHiburan = 'kat-hiburan';
  static const katLain = 'kat-lain'; 

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

  static List<Transaksi> transaksi() => [
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
}