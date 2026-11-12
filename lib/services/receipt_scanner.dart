import 'dart:typed_data';

import '../models/hasil_scan.dart';
import '../models/kategori.dart';

/// Galat pemindaian dengan pesan ramah pengguna.
class ScanException implements Exception {
  final String pesan;

  /// True jika penyebabnya kuota AI gratis habis (HTTP 429).
  final bool kuotaHabis;

  /// Keterangan teknis (nama model, galat asli) untuk pemecahan masalah.
  final String? detail;

  const ScanException(this.pesan, {this.kuotaHabis = false, this.detail});

  @override
  String toString() => pesan;
}

/// Kontrak pemindai struk. Implementasi: GeminiReceiptScanner dan MockReceiptScanner.
abstract class ReceiptScanner {
  Future<HasilScan> pindai({
    required Uint8List gambar,
    required String mimeType,
    required List<Kategori> kategori,
  });
}