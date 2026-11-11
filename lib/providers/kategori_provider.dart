import 'package:flutter/foundation.dart';

import '../models/kategori.dart';
import '../repositories/kategori_repository.dart';
import '../utils/helpers.dart';

/// State bersama modul Kategori (data referensi) dengan CRUD lengkap.
class KategoriProvider extends ChangeNotifier {
  KategoriProvider(this._repo);

  final KategoriRepository _repo;

  List<Kategori> _items = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _simulasiGagal = false;

  List<Kategori> get items => List.unmodifiable(_items);
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isEmpty => _status == LoadStatus.success && _items.isEmpty;

  /// Saklar demo: jika true, operasi berpura-pura gagal.
  bool get simulasiGagal => _simulasiGagal;
  set simulasiGagal(bool nilai) {
    if (nilai == _simulasiGagal) return;
    _simulasiGagal = nilai;
    notifyListeners();
  }

  String? _uid;

  /// Dipanggil saat pengguna berganti (masuk/keluar): kosongkan data lama lalu
  /// muat data milik pengguna yang baru.
  void sinkronkanPengguna(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    Future.microtask(() {
      _items = [];
      _status = LoadStatus.initial;
      _errorMessage = null;
      notifyListeners();
      if (uid != null) muat();
    });
  }

  Kategori? byId(String id) {
    for (final k in _items) {
      if (k.id == id) return k;
    }
    return null;
  }

  /// Nama kategori untuk ditampilkan; aman jika ID tidak ditemukan.
  String namaDari(String id) => byId(id)?.nama ?? 'Tidak diketahui';

  /// Apakah nama sudah dipakai kategori lain (tanpa membedakan huruf besar/kecil).
  bool namaTerpakai(String nama, {String? kecualiId}) {
    final n = nama.trim().toLowerCase();
    return _items.any((k) => k.id != kecualiId && k.nama.trim().toLowerCase() == n);
  }

  Future<void> muat() async {
    if (_status == LoadStatus.loading) return;
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _cekSimulasi('memuat');
      _items = await _repo.getAll();
      _status = LoadStatus.success;
    } catch (e) {
      _status = LoadStatus.error;
      _errorMessage = _bersihkan(e);
    }
    notifyListeners();
  }

  Future<bool> tambah(Kategori k) => _jalankan('menyimpan', () async {
        await _repo.tambah(k);
        _items = [..._items, k];
      });

  Future<bool> ubah(Kategori k) => _jalankan('menyimpan', () async {
        await _repo.ubah(k);
        _items = [for (final e in _items) e.id == k.id ? k : e];
      });

  Future<bool> hapus(String id) => _jalankan('menghapus', () async {
        await _repo.hapus(id);
        _items = _items.where((e) => e.id != id).toList();
      });

  Future<bool> _jalankan(String namaAksi, Future<void> Function() aksi) async {
    if (_isSubmitting) return false; // cegah submit ganda
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    var berhasil = false;
    try {
      await _cekSimulasi(namaAksi);
      await aksi();
      berhasil = true;
    } catch (e) {
      _errorMessage = _bersihkan(e);
    }
    _isSubmitting = false;
    notifyListeners();
    return berhasil;
  }

  Future<void> _cekSimulasi(String namaAksi) async {
    if (!_simulasiGagal) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    throw Exception('Simulasi gagal $namaAksi data');
  }

  String _bersihkan(Object e) => e.toString().replaceFirst('Exception: ', '');
}