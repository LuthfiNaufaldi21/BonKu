import 'package:flutter/foundation.dart';

import '../models/transaksi.dart';
import '../repositories/transaksi_repository.dart';
import '../utils/helpers.dart';

/// State bersama untuk modul Transaksi. Semua layar membaca data dari sini,
/// sehingga perubahan di satu layar langsung terlihat di layar lain.
/// Provider memperbarui daftar lokalnya sendiri setelah repository berhasil,
/// jadi tidak bergantung pada jenis repository (memori atau Firestore).
class TransaksiProvider extends ChangeNotifier {
  TransaksiProvider(this._repo);

  final TransaksiRepository _repo;

  List<Transaksi> _items = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _simulasiGagal = false;

  List<Transaksi> get items => List.unmodifiable(_items);
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isEmpty => _status == LoadStatus.success && _items.isEmpty;

  /// Saklar demo: jika true, semua operasi berpura-pura gagal.
  bool get simulasiGagal => _simulasiGagal;
  set simulasiGagal(bool nilai) {
    if (nilai == _simulasiGagal) return;
    _simulasiGagal = nilai;
    notifyListeners();
  }

  Transaksi? byId(String id) {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> muat() async {
    if (_status == LoadStatus.loading) return; // cegah pemanggilan ganda
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _cekSimulasi('memuat');
      _items = _urutkan(await _repo.getAll());
      _status = LoadStatus.success;
    } catch (e) {
      _status = LoadStatus.error;
      _errorMessage = _bersihkan(e);
    }
    notifyListeners();
  }

  /// Mengembalikan true jika berhasil. Jika gagal, lihat [errorMessage].
  Future<bool> tambah(Transaksi t) => _jalankan('menyimpan', () async {
        await _repo.tambah(t);
        _items = _urutkan([..._items, t]);
      });

  Future<bool> ubah(Transaksi t) => _jalankan('menyimpan', () async {
        await _repo.ubah(t);
        _items = _urutkan([for (final e in _items) e.id == t.id ? t : e]);
      });

  Future<bool> hapus(String id) => _jalankan('menghapus', () async {
        await _repo.hapus(id);
        _items = _items.where((e) => e.id != id).toList();
      });

  /// Fitur demo: kosongkan semua transaksi / pulihkan data awal.
  Future<bool> kosongkan() => _jalankan('menghapus', () async {
        await _repo.kosongkan();
        _items = [];
      });

  Future<bool> pulihkan() => _jalankan('memulihkan', () async {
        await _repo.pulihkan();
        _items = _urutkan(await _repo.getAll());
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
    await Future<void>.delayed(const Duration(milliseconds: 700));
    throw Exception('Simulasi gagal $namaAksi data');
  }

  List<Transaksi> _urutkan(List<Transaksi> data) =>
      [...data]..sort((a, b) => b.tanggal.compareTo(a.tanggal));

  String _bersihkan(Object e) => e.toString().replaceFirst('Exception: ', '');
}