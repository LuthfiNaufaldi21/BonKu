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

  bool simulasiGagal = false;

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
      _items = await _repo.getAll(simulateError: simulasiGagal);
      _status = LoadStatus.success;
    } catch (e) {
      _status = LoadStatus.error;
      _errorMessage = _bersihkan(e);
    }
    notifyListeners();
  }

  Future<bool> tambah(Transaksi t) =>
      _jalankan(() => _repo.tambah(t, simulateError: simulasiGagal));

  Future<bool> ubah(Transaksi t) =>
      _jalankan(() => _repo.ubah(t, simulateError: simulasiGagal));

  Future<bool> hapus(String id) =>
      _jalankan(() => _repo.hapus(id, simulateError: simulasiGagal));

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