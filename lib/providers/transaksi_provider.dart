import 'package:flutter/foundation.dart';

import '../models/transaksi.dart';
import '../repositories/transaksi_repository.dart';
import '../utils/helpers.dart';

class TransaksiProvider extends ChangeNotifier {
  TransaksiProvider(this._repo);

  final TransaksiRepository _repo;

  List<Transaksi> _items = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;
  bool _isSubmitting = false;

  bool _simulasiGagal = false;

  bool get simulasiGagal => _simulasiGagal;
  set simulasiGagal(bool nilai) {
    if (nilai == _simulasiGagal) return;
    _simulasiGagal = nilai;
    notifyListeners();
  }

  List<Transaksi> get items => List.unmodifiable(_items);
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isEmpty => _status == LoadStatus.success && _items.isEmpty;

  Transaksi? byId(String id) {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
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

  Future<bool> tambah(Transaksi t) =>
      _jalankan(() => _repo.tambah(t, simulateError: _simulasiGagal));

  Future<bool> ubah(Transaksi t) =>
      _jalankan(() => _repo.ubah(t, simulateError: _simulasiGagal));

  Future<bool> hapus(String id) =>
      _jalankan(() => _repo.hapus(id, simulateError: _simulasiGagal));

  Future<bool> kosongkan() =>
      _jalankan(() => _repo.kosongkan(simulateError: _simulasiGagal));

  Future<bool> pulihkan() =>
      _jalankan(() => _repo.pulihkan(simulateError: _simulasiGagal));

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