import 'dart:typed_data';

import '../data/seed_data.dart';
import '../models/hasil_scan.dart';
import '../models/kategori.dart';
import 'receipt_scanner.dart';

/// Pemindai palsu untuk pengembangan dan demo: tidak memakai kuota Gemini.
/// Mengembalikan tiga contoh struk secara bergiliran.
class MockReceiptScanner implements ReceiptScanner {
  MockReceiptScanner({this.jeda = const Duration(milliseconds: 1500)});

  final Duration jeda;
  int _giliran = 0;

  @override
  Future<HasilScan> pindai({
    required Uint8List gambar,
    required String mimeType,
    required List<Kategori> kategori,
  }) async {
    await Future<void>.delayed(jeda);
    final waktu = DateTime.now().subtract(const Duration(minutes: 5));

    switch (_giliran++ % 3) {
      case 0:
        return HasilScan(
          toko: 'Indomaret Setia Budi',
          tanggal: waktu,
          simulasi: true,
          items: const [
            ItemScan(nama: 'Air Mineral 600ml', kategoriId: SeedData.katKonsumsi, harga: 4000),
            ItemScan(nama: 'Roti Sobek', kategoriId: SeedData.katKonsumsi, harga: 12500),
            ItemScan(nama: 'Tisu Wajah', kategoriId: SeedData.katLain, harga: 9000),
          ],
        );
      case 1:
        return HasilScan(
          toko: 'Apotek K-24',
          tanggal: waktu,
          simulasi: true,
          items: const [
            ItemScan(nama: 'Vitamin C 500mg', kategoriId: SeedData.katKesehatan, harga: 35000),
            ItemScan(nama: 'Masker Medis', kategoriId: SeedData.katKesehatan, harga: 15000),
          ],
        );
      default:
        return HasilScan(
          toko: 'Gramedia Medan',
          tanggal: waktu,
          simulasi: true,
          items: const [
            ItemScan(nama: 'Buku Tulis Sinar Dunia', kategoriId: SeedData.katEdukasi, harga: 15000),
            ItemScan(nama: 'Pulpen Gel', kategoriId: SeedData.katEdukasi, harga: 12000),
            ItemScan(nama: 'Barang Tidak Jelas', kategoriId: SeedData.katLain, harga: 50000),
          ],
        );
    }
  }
}