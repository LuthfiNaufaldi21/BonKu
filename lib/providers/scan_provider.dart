import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../models/hasil_scan.dart';
import '../models/kategori.dart';
import '../services/receipt_scanner.dart';

/// Memilih pemindai yang dipakai: Gemini asli atau simulasi (hemat kuota).
class ScanProvider extends ChangeNotifier {
  ScanProvider({required ReceiptScanner asli, required ReceiptScanner simulasi})
      : _asli = asli,
        _simulasi = simulasi;

  final ReceiptScanner _asli;
  final ReceiptScanner _simulasi;
  bool _pakaiSimulasi = false;

  bool get pakaiSimulasi => _pakaiSimulasi;

  void setPakaiSimulasi(bool nilai) {
    if (nilai == _pakaiSimulasi) return;
    _pakaiSimulasi = nilai;
    notifyListeners();
  }

  /// [paksaSimulasi] dipakai sebagai cadangan saat kuota AI habis.
  Future<HasilScan> pindai({
    required Uint8List gambar,
    required String mimeType,
    required List<Kategori> kategori,
    bool paksaSimulasi = false,
  }) {
    final pemindai = (paksaSimulasi || _pakaiSimulasi) ? _simulasi : _asli;
    return pemindai.pindai(gambar: gambar, mimeType: mimeType, kategori: kategori);
  }
}