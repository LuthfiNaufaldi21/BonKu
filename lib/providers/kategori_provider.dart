import 'package:flutter/foundation.dart';

import '../models/kategori.dart';
import '../repositories/kategori_repository.dart';
import '../utils/helpers.dart';

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

  bool get simulasiGagal => _simulasiGagal;
  set simulasiGagal(bool nilai) {
    if (nilai == _simulasiGagal) return;
    _simulasiGagal = nilai;
    notifyListeners();
  }

  Kategori? byId(String id) {
    for (final k in _items) {
      if (k.id == id) return k;
    }
    return null;
  }

  String namaDari(String id) => byId(id)?.nama ?? 'Tidak diketahui';

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
      _items = await _repo.getAll(simulateError: _simulasiGagal);
      _status = LoadStatus.success;
    } catch (e) {
      _status = LoadStatus.error;
      _errorMessage = _bersihkan(e);
    }
    notifyListeners();
  }

  Future<bool> tambah(Kategori k) =>
      _jalankan(() => _repo.tambah(k, simulateError: _simulasiGagal));

  Future<bool> ubah(Kategori k) =>
      _jalankan(() => _repo.ubah(k, simulateError: _simulasiGagal));

  Future<bool> hapus(String id) =>
      _jalankan(() => _repo.hapus(id, simulateError: _simulasiGagal));

  Future<bool> _jalankan(Future<void> Function() aksi) async {
    if (_isSubmitting) return false; 
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    var berhasil = false;
    try {
      await aksi();
      _items = _repo.snapshot;
      berhasil = true;
    } catch (e) {
      _errorMessage = _bersihkan(e);
    }
    _isSubmitting = false;
    notifyListeners();
    return berhasil;
  }

  String _bersihkan(Object e) => e.toString().replaceFirst('Exception: ', '');
}