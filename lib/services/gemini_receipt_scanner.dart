import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/hasil_scan.dart';
import '../models/kategori.dart';
import 'receipt_scanner.dart';

/// Membaca struk dengan Gemini lewat Firebase AI Logic (Gemini Developer API).
/// Kunci API tidak ada di aplikasi; permintaan lewat proxy proyek Firebase.
///
/// Model Gemini 2.5 sudah dipensiunkan (Oktober 2026), jadi dicoba model-model
/// yang lebih baru secara berurutan. Model pertama yang berhasil diingat dan
/// dipakai seterusnya. Ubah daftar ini jika ketersediaan model berubah.
class GeminiReceiptScanner implements ReceiptScanner {
  GeminiReceiptScanner({List<String>? kandidatModel})
      : _kandidat = kandidatModel ?? kandidatBawaan;

  static const kandidatBawaan = [
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash',
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.6-flash',
  ];

  final List<String> _kandidat;
  final Map<String, GenerativeModel> _model = {};
  String? _modelBerhasil;

  GenerativeModel _ambilModel(String nama) => _model.putIfAbsent(
        nama,
        () => FirebaseAI.googleAI().generativeModel(
          model: nama,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.1,
            maxOutputTokens: 8192, // model baru "berpikir" dulu; beri ruang cukup
          ),
        ),
      );

  @override
  Future<HasilScan> pindai({
    required Uint8List gambar,
    required String mimeType,
    required List<Kategori> kategori,
  }) async {
    final namaKategori = [for (final k in kategori) k.nama];
    final namaLain = kategori
            .where((k) => k.id == SeedData.katLain)
            .map((k) => k.nama)
            .firstOrNull ??
        'Lain-lain / Belum Dikategorikan';
    final prompt = _susunPrompt(namaKategori, namaLain);

    final urutan = _modelBerhasil != null ? [_modelBerhasil!] : _kandidat;
    final dicoba = <String>[];
    Object? galatTerakhir;

    for (final nama in urutan) {
      dicoba.add(nama);
      try {
        final respons = await _ambilModel(nama)
            .generateContent([
              Content.multi([TextPart(prompt), InlineDataPart(mimeType, gambar)]),
            ])
            .timeout(const Duration(seconds: 40));

        final teks = respons.text;
        if (teks == null || teks.trim().isEmpty) {
          throw ScanException(
            'AI tidak mengembalikan hasil. Coba foto yang lebih jelas.',
            detail: 'Respons kosong dari model $nama.',
          );
        }
        final hasil = _urai(teks, kategori, nama);
        _modelBerhasil = nama;
        debugPrint('Gemini OK dengan model $nama');
        return hasil;
      } on ScanException {
        rethrow;
      } on TimeoutException {
        throw ScanException(
          'Pembacaan terlalu lama. Periksa koneksi lalu coba lagi.',
          detail: 'Timeout pada model $nama.',
        );
      } catch (e) {
        debugPrint('Gemini error ($nama): $e');
        galatTerakhir = e;
        if (_modelBerhasil == nama) _modelBerhasil = null; // model ini tidak lagi bisa dipakai
        if (_bolehCobaModelLain(e) && nama != urutan.last) continue;
        throw _petakan(e, dicoba);
      }
    }
    throw _petakan(galatTerakhir ?? 'Tidak ada model yang dicoba.', dicoba);
  }

  /// Model tidak ada (404) atau kuotanya habis: coba model lain.
  bool _bolehCobaModelLain(Object e) {
    final t = e.toString().toLowerCase();
    return t.contains('404') ||
        t.contains('not found') ||
        t.contains('not_found') ||
        t.contains('no longer available') ||
        t.contains('not supported') ||
        t.contains('429') ||
        t.contains('quota') ||
        t.contains('resource_exhausted');
  }

  String _susunPrompt(List<String> namaKategori, String namaLain) => '''
Kamu adalah pembaca struk belanja dan bukti pembayaran digital (kasir, m-banking, e-wallet) berbahasa Indonesia.
Dari gambar, ekstrak data pengeluaran dan balas HANYA dengan JSON berbentuk:
{"toko": string, "tanggal": "YYYY-MM-DD" atau null, "jam": "HH:mm" atau null, "items": [{"nama": string, "harga": integer, "kategori": string}]}

Aturan:
- "harga" adalah subtotal item dalam Rupiah, bilangan bulat tanpa titik, koma, atau simbol (contoh: 25000).
- Satu baris per barang atau jasa. Jika hanya ada total tanpa rincian (mis. bukti transfer atau e-wallet), buat satu item yang menggambarkan transaksinya dengan harga sama dengan total.
- Abaikan baris Total, Subtotal keseluruhan, Tunai, Kembalian, dan Pembulatan.
- Abaikan aktivitas yang bukan pengeluaran: Tarik Tunai, Top-Up atau isi saldo, dan transfer ke rekening sendiri.
- "kategori" harus salah satu dari daftar ini, persis sama penulisannya: ${namaKategori.join(', ')}.
- Jika konteks barang tidak jelas, pakai kategori "$namaLain".
- Jika gambar bukan struk atau tidak terbaca, kembalikan {"toko": "", "tanggal": null, "jam": null, "items": []}.
''';

  HasilScan _urai(String mentah, List<Kategori> kategori, String model) {
    var teks = mentah.trim();
    if (teks.startsWith('```')) {
      teks = teks.replaceAll(RegExp(r'^```(?:json)?\s*|\s*```$'), '').trim();
    }

    Object? data;
    try {
      data = jsonDecode(teks);
    } catch (_) {
      throw ScanException(
        'Hasil AI tidak bisa dibaca. Coba foto ulang.',
        detail: 'JSON tidak valid dari $model. Awal respons: ${_potong(teks, 200)}',
      );
    }
    if (data is! Map<String, dynamic>) {
      throw ScanException(
        'Hasil AI tidak bisa dibaca. Coba foto ulang.',
        detail: 'Bentuk JSON tidak sesuai dari $model: ${_potong(teks, 200)}',
      );
    }

    final peta = {for (final k in kategori) k.nama.toLowerCase().trim(): k.id};
    String idKategori(Object? nama) =>
        peta[(nama ?? '').toString().toLowerCase().trim()] ?? SeedData.katLain;

    final items = <ItemScan>[];
    for (final r in (data['items'] as List<dynamic>? ?? const [])) {
      if (r is! Map) continue;
      var nama = (r['nama'] ?? '').toString().trim();
      final harga = _keInt(r['harga']);
      if (nama.isEmpty || harga == null || harga <= 0) continue;
      if (nama.length > 40) nama = nama.substring(0, 40).trimRight();
      items.add(ItemScan(nama: nama, kategoriId: idKategori(r['kategori']), harga: harga));
    }

    if (items.isEmpty) {
      throw ScanException(
        'Tidak ada pengeluaran yang terbaca. Pastikan foto jelas dan memuat rincian belanja.',
        detail: 'Daftar item kosong dari $model. Respons: ${_potong(teks, 200)}',
      );
    }

    var toko = (data['toko'] ?? '').toString().trim();
    if (toko.length > 50) toko = toko.substring(0, 50).trimRight();

    DateTime? tanggal;
    final tgl = (data['tanggal'] ?? '').toString().trim();
    if (tgl.isNotEmpty) {
      final jam = (data['jam'] ?? '').toString().trim();
      tanggal = DateTime.tryParse(jam.isEmpty ? tgl : '$tgl $jam') ?? DateTime.tryParse(tgl);
    }
    if (tanggal != null && (tanggal.isAfter(DateTime.now()) || tanggal.year < 2020)) {
      tanggal = null; // tidak masuk akal, biarkan form memakai waktu sekarang
    }

    return HasilScan(toko: toko, tanggal: tanggal, items: items);
  }

  int? _keInt(Object? v) {
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    return null;
  }

  String _potong(String s, int maks) => s.length <= maks ? s : '${s.substring(0, maks)}...';

  /// Menerjemahkan galat teknis menjadi pesan yang mudah dipahami.
  ScanException _petakan(Object e, List<String> dicoba) {
    final t = e.toString().toLowerCase();
    final detail = 'Model dicoba: ${dicoba.join(', ')}\n${_potong(e.toString(), 400)}';

    if (t.contains('app check') || t.contains('appcheck') || t.contains('app_check')) {
      return ScanException(
        'App Check belum siap. Daftarkan token debug di Firebase Console (Security, App Check).',
        detail: detail,
      );
    }
    if (t.contains('404') || t.contains('not found') || t.contains('not_found')) {
      return ScanException(
        'Model AI tidak tersedia. Daftar model di GeminiReceiptScanner perlu diperbarui.',
        detail: detail,
      );
    }
    if (t.contains('429') ||
        t.contains('quota') ||
        t.contains('resource_exhausted') ||
        t.contains('rate limit') ||
        t.contains('too many')) {
      return ScanException(
        'Kuota AI gratis sedang habis. Coba lagi nanti, isi manual, atau pakai pemindai simulasi.',
        kuotaHabis: true,
        detail: detail,
      );
    }
    if (t.contains('not been used') ||
        t.contains('not enabled') ||
        t.contains('service_disabled') ||
        t.contains('api has not')) {
      return ScanException(
        'Firebase AI Logic belum aktif untuk proyek ini. Aktifkan di Firebase Console, menu AI Logic.',
        detail: detail,
      );
    }
    if (t.contains('permission') || t.contains('403')) {
      return ScanException(
        'Akses ke layanan AI ditolak. Periksa pengaturan AI Logic dan App Check di Firebase Console.',
        detail: detail,
      );
    }
    if (t.contains('socket') ||
        t.contains('network') ||
        t.contains('unavailable') ||
        t.contains('host lookup') ||
        t.contains('connection')) {
      return ScanException('Tidak ada koneksi internet. Coba lagi.', detail: detail);
    }
    return ScanException('Gagal membaca struk. Coba lagi.', detail: detail);
  }
}